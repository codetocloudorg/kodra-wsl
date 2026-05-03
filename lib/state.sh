#!/usr/bin/env bash
#
# Kodra WSL Install State / Resume
#
# Tracks which install modules have completed so `kodra resume` can pick up
# where it left off.
#

KODRA_STATE_FILE="${HOME}/.config/kodra/install-state.json"

# Initialize state file
init_state() {
    local state_dir
    state_dir="$(dirname "${KODRA_STATE_FILE}")"
    mkdir -p "${state_dir}"

    if [ ! -f "${KODRA_STATE_FILE}" ]; then
        cat > "${KODRA_STATE_FILE}" << 'EOF'
{
  "version": "1",
  "started_at": "",
  "updated_at": "",
  "steps": {}
}
EOF
    fi

    # Record start time
    save_state "started_at" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    save_state "updated_at" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}

# Save a top-level key into the state file
save_state() {
    local key="$1"
    local value="$2"

    if [ ! -f "${KODRA_STATE_FILE}" ]; then
        init_state
    fi

    # Use python3 for reliable JSON manipulation (available on Ubuntu)
    python3 -c "
import json, sys
with open('${KODRA_STATE_FILE}', 'r') as f:
    data = json.load(f)
data['${key}'] = '${value}'
with open('${KODRA_STATE_FILE}', 'w') as f:
    json.dump(data, f, indent=2)
"
}

# Load a top-level key from the state file
load_state() {
    local key="$1"

    if [ ! -f "${KODRA_STATE_FILE}" ]; then
        return 1
    fi

    python3 -c "
import json
with open('${KODRA_STATE_FILE}', 'r') as f:
    data = json.load(f)
print(data.get('${key}', ''))
"
}

# Mark a step as complete
mark_step_complete() {
    local step="$1"

    if [ ! -f "${KODRA_STATE_FILE}" ]; then
        init_state
    fi

    python3 -c "
import json
with open('${KODRA_STATE_FILE}', 'r') as f:
    data = json.load(f)
if 'steps' not in data:
    data['steps'] = {}
data['steps']['${step}'] = {'status': 'complete', 'timestamp': '$(date -u +%Y-%m-%dT%H:%M:%SZ)'}
data['updated_at'] = '$(date -u +%Y-%m-%dT%H:%M:%SZ)'
with open('${KODRA_STATE_FILE}', 'w') as f:
    json.dump(data, f, indent=2)
"
}

# Check if a step is complete (return 0 if complete)
is_step_complete() {
    local step="$1"

    if [ ! -f "${KODRA_STATE_FILE}" ]; then
        return 1
    fi

    python3 -c "
import json, sys
with open('${KODRA_STATE_FILE}', 'r') as f:
    data = json.load(f)
status = data.get('steps', {}).get('${step}', {}).get('status', '')
sys.exit(0 if status == 'complete' else 1)
"
}

# Mark a step as failed
mark_step_failed() {
    local step="$1"
    local reason="${2:-unknown}"

    if [ ! -f "${KODRA_STATE_FILE}" ]; then
        init_state
    fi

    python3 -c "
import json
with open('${KODRA_STATE_FILE}', 'r') as f:
    data = json.load(f)
if 'steps' not in data:
    data['steps'] = {}
data['steps']['${step}'] = {'status': 'failed', 'reason': '${reason}', 'timestamp': '$(date -u +%Y-%m-%dT%H:%M:%SZ)'}
data['updated_at'] = '$(date -u +%Y-%m-%dT%H:%M:%SZ)'
with open('${KODRA_STATE_FILE}', 'w') as f:
    json.dump(data, f, indent=2)
"
}

# Get list of failed steps
get_failed_steps() {
    if [ ! -f "${KODRA_STATE_FILE}" ]; then
        return
    fi

    python3 -c "
import json
with open('${KODRA_STATE_FILE}', 'r') as f:
    data = json.load(f)
for name, info in data.get('steps', {}).items():
    if info.get('status') == 'failed':
        print(name)
"
}

# Get list of pending steps (not yet started)
get_pending_steps() {
    local all_steps="$1"  # space-separated list of all expected steps

    if [ ! -f "${KODRA_STATE_FILE}" ]; then
        echo "${all_steps}"
        return
    fi

    python3 -c "
import json
with open('${KODRA_STATE_FILE}', 'r') as f:
    data = json.load(f)
recorded = data.get('steps', {})
for step in '${all_steps}'.split():
    if step not in recorded:
        print(step)
"
}

# Get the first incomplete step (resume point)
get_resume_point() {
    local all_steps="$1"  # space-separated ordered list of all steps

    if [ ! -f "${KODRA_STATE_FILE}" ]; then
        echo "${all_steps%% *}"
        return
    fi

    python3 -c "
import json, sys
with open('${KODRA_STATE_FILE}', 'r') as f:
    data = json.load(f)
recorded = data.get('steps', {})
for step in '${all_steps}'.split():
    status = recorded.get(step, {}).get('status', '')
    if status != 'complete':
        print(step)
        sys.exit(0)
print('')
"
}

# Clear all state
clear_state() {
    if [ -f "${KODRA_STATE_FILE}" ]; then
        rm -f "${KODRA_STATE_FILE}"
    fi
}

# Show a summary of install state
show_state_summary() {
    if [ ! -f "${KODRA_STATE_FILE}" ]; then
        echo -e "    ${C_YELLOW}${BOX_WARN}${C_RESET} No install state found"
        return
    fi

    python3 -c "
import json
with open('${KODRA_STATE_FILE}', 'r') as f:
    data = json.load(f)
steps = data.get('steps', {})
complete = sum(1 for s in steps.values() if s.get('status') == 'complete')
failed = sum(1 for s in steps.values() if s.get('status') == 'failed')
total = len(steps)
print(f'    Steps: {total} total, {complete} complete, {failed} failed')
if data.get('started_at'):
    print(f'    Started: {data[\"started_at\"]}')
if data.get('updated_at'):
    print(f'    Updated: {data[\"updated_at\"]}')
"
}

# Get install progress as "complete/total" string
get_install_progress() {
    if [ ! -f "${KODRA_STATE_FILE}" ]; then
        echo "0/0"
        return
    fi

    python3 -c "
import json
with open('${KODRA_STATE_FILE}', 'r') as f:
    data = json.load(f)
steps = data.get('steps', {})
complete = sum(1 for s in steps.values() if s.get('status') == 'complete')
total = len(steps)
print(f'{complete}/{total}')
"
}

# Check if resume is possible (state exists and has incomplete steps)
can_resume() {
    if [ ! -f "${KODRA_STATE_FILE}" ]; then
        return 1
    fi

    python3 -c "
import json, sys
with open('${KODRA_STATE_FILE}', 'r') as f:
    data = json.load(f)
steps = data.get('steps', {})
has_incomplete = any(s.get('status') != 'complete' for s in steps.values())
has_any = len(steps) > 0
sys.exit(0 if has_any and has_incomplete else 1)
"
}
