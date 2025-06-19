# Bash Scripting Guide

Scripting is the most powerful that a Student and Developer must have. \
We can automate the specific by using the power of bash scripting\
A comprehensive guide to bash scripting fundamentals, advanced techniques, and best practices.

## Table of Contents

- [Getting Started](#getting-started)
- [Basic Syntax](#basic-syntax)
- [Variables](#variables)
- [Control Structures](#control-structures)
- [Functions](#functions)
- [File Operations](#file-operations)
- [Advanced Features](#advanced-features)
- [Best Practices](#best-practices)
- [Common Examples](#common-examples)

## Getting Started

### Creating Your First Script

```bash
#!/bin/bash
# This is a comment
echo "Hello, World!"
```

### Making Scripts Executable

```bash
chmod +x script.sh
./script.sh
```

### Shebang Lines

```bash
#!/bin/bash          # Standard bash
#!/usr/bin/env bash  # Portable bash
#!/bin/sh            # POSIX shell
```

## Basic Syntax

### Comments

```bash
# Single line comment
: '
Multi-line comment
Everything between the quotes is ignored
'
```

### Echo and Print

```bash
echo "Hello World"
echo -n "No newline"
echo -e "Line 1\nLine 2"  # Enable escape sequences
printf "Formatted: %s %d\n" "text" 42
```

## Variables

### Variable Declaration and Usage

```bash
# Declaration
name="John"
age=25
readonly PI=3.14159

# Usage
echo "Name: $name"
echo "Age: ${age}"
echo "Next year: $((age + 1))"
```

### Special Variables

```bash
$0    # Script name
$1    # First argument
$#    # Number of arguments
$@    # All arguments as separate words
$*    # All arguments as single word
$?    # Exit status of last command
$$    # Process ID of current shell
```

### Environment Variables

```bash
export PATH="/usr/local/bin:$PATH"
export DATABASE_URL="postgresql://localhost/mydb"

# Check if variable exists
if [ -z "$HOME" ]; then
    echo "HOME not set"
fi
```

## Control Structures

### Conditional Statements

```bash
# If-else
if [ "$age" -ge 18 ]; then
    echo "Adult"
elif [ "$age" -ge 13 ]; then
    echo "Teenager"
else
    echo "Child"
fi

# Case statement
case "$1" in
    start)
        echo "Starting service..."
        ;;
    stop)
        echo "Stopping service..."
        ;;
    restart)
        echo "Restarting service..."
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac
```

### Comparison Operators

```bash
# Numeric comparisons
-eq  # Equal
-ne  # Not equal
-lt  # Less than
-le  # Less than or equal
-gt  # Greater than
-ge  # Greater than or equal

# String comparisons
=    # Equal
!=   # Not equal
-z   # Empty string
-n   # Non-empty string

# File tests
-f   # Regular file exists
-d   # Directory exists
-r   # Readable
-w   # Writable
-x   # Executable
```

### Loops

```bash
# For loop
for i in {1..5}; do
    echo "Number: $i"
done

# For loop with array
fruits=("apple" "banana" "orange")
for fruit in "${fruits[@]}"; do
    echo "Fruit: $fruit"
done

# While loop
counter=1
while [ $counter -le 5 ]; do
    echo "Counter: $counter"
    ((counter++))
done

# Until loop
until [ $counter -gt 10 ]; do
    echo "Counter: $counter"
    ((counter++))
done
```

## Functions

### Function Definition

```bash
# Method 1
function greet() {
    echo "Hello, $1!"
}

# Method 2
calculate_sum() {
    local num1=$1
    local num2=$2
    local sum=$((num1 + num2))
    echo $sum
}

# Function with return value
is_even() {
    local number=$1
    if [ $((number % 2)) -eq 0 ]; then
        return 0  # True
    else
        return 1  # False
    fi
}

# Usage
greet "Alice"
result=$(calculate_sum 10 20)
echo "Sum: $result"

if is_even 4; then
    echo "4 is even"
fi
```

## File Operations

### Reading Files

```bash
# Read line by line
while IFS= read -r line; do
    echo "Line: $line"
done < "file.txt"

# Read entire file
content=$(cat "file.txt")
echo "$content"

# Check if file exists
if [ -f "file.txt" ]; then
    echo "File exists"
fi
```

### Writing Files

```bash
# Write to file (overwrite)
echo "Hello World" > output.txt

# Append to file
echo "Second line" >> output.txt

# Write multiple lines
cat << EOF > config.txt
server=localhost
port=8080
database=mydb
EOF
```

### File Manipulation

```bash
# Copy, move, delete
cp source.txt destination.txt
mv old_name.txt new_name.txt
rm unwanted.txt

# Create directory
mkdir -p /path/to/directory

# Find files
find /path -name "*.txt" -type f
find /path -mtime -7  # Modified in last 7 days
```

## Advanced Features

### Arrays

```bash
# Declare array
declare -a fruits=("apple" "banana" "orange")

# Add elements
fruits+=("grape")
fruits[10]="mango"

# Access elements
echo "First: ${fruits[0]}"
echo "All: ${fruits[@]}"
echo "Length: ${#fruits[@]}"

# Loop through array
for fruit in "${fruits[@]}"; do
    echo "$fruit"
done
```

### String Manipulation

```bash
text="Hello World"

# Length
echo ${#text}

# Substring
echo ${text:0:5}    # "Hello"
echo ${text:6}      # "World"

# Replace
echo ${text/World/Universe}    # "Hello Universe"
echo ${text//l/L}              # "HeLLo WorLd"

# Case conversion
echo ${text^^}      # "HELLO WORLD"
echo ${text,,}      # "hello world"
```

### Command Substitution

```bash
# Modern syntax
current_date=$(date)
file_count=$(ls -1 | wc -l)

# Legacy syntax (avoid)
current_date=`date`

# Process substitution
diff <(ls dir1) <(ls dir2)
```

### Error Handling

```bash
# Exit on error
set -e

# Function with error handling
backup_file() {
    local source=$1
    local destination=$2
    
    if [ ! -f "$source" ]; then
        echo "Error: Source file '$source' not found" >&2
        return 1
    fi
    
    if cp "$source" "$destination"; then
        echo "Backup successful"
    else
        echo "Error: Backup failed" >&2
        return 1
    fi
}

# Trap for cleanup
cleanup() {
    echo "Cleaning up..."
    rm -f /tmp/tempfile
}
trap cleanup EXIT
```

## Best Practices

### Script Structure

```bash
#!/bin/bash
set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Global variables
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"

# Configuration
CONFIG_FILE="${SCRIPT_DIR}/config.conf"
LOG_FILE="${SCRIPT_DIR}/script.log"

# Functions
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS] COMMAND

COMMANDS:
    start       Start the service
    stop        Stop the service
    status      Check service status

OPTIONS:
    -h, --help     Show this help message
    -v, --verbose  Enable verbose output
    -c, --config   Specify config file

EOF
}

# Main function
main() {
    local verbose=false
    local command=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            *)
                command="$1"
                shift
                ;;
        esac
    done
    
    # Validate command
    if [[ -z "$command" ]]; then
        echo "Error: No command specified" >&2
        usage
        exit 1
    fi
    
    # Execute command
    case "$command" in
        start|stop|status)
            log "Executing: $command"
            # Add your logic here
            ;;
        *)
            echo "Error: Unknown command '$command'" >&2
            usage
            exit 1
            ;;
    esac
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

### Security Considerations

```bash
# Quote variables to prevent word splitting
echo "$USER_INPUT"

# Use arrays for command arguments
command_args=("--flag" "$user_value" "--another-flag")
some_command "${command_args[@]}"

# Validate input
validate_email() {
    local email=$1
    if [[ $email =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}
```

## Common Examples

### System Information Script

```bash
#!/bin/bash

echo "=== System Information ==="
echo "Hostname: $(hostname)"
echo "OS: $(uname -s)"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo "Load Average: $(uptime | cut -d',' -f3-)"
echo "Memory Usage: $(free -h | grep '^Mem:' | awk '{print $3 "/" $2}')"
echo "Disk Usage: $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 ")"}')"
```

### Log Rotation Script

```bash
#!/bin/bash

LOG_DIR="/var/log/myapp"
MAX_SIZE="100M"
BACKUP_COUNT=5

rotate_log() {
    local log_file=$1
    
    if [[ ! -f "$log_file" ]]; then
        return 0
    fi
    
    local file_size=$(stat -f%z "$log_file" 2>/dev/null || stat -c%s "$log_file")
    local max_bytes=$((100 * 1024 * 1024))  # 100MB
    
    if [[ $file_size -gt $max_bytes ]]; then
        echo "Rotating $log_file"
        
        # Rotate existing backups
        for ((i=BACKUP_COUNT; i>=1; i--)); do
            if [[ -f "${log_file}.${i}" ]]; then
                mv "${log_file}.${i}" "${log_file}.$((i + 1))"
            fi
        done
        
        # Create new backup
        mv "$log_file" "${log_file}.1"
        touch "$log_file"
    fi
}

# Rotate all log files
for log_file in "$LOG_DIR"/*.log; do
    rotate_log "$log_file"
done
```

### Backup Script

```bash
#!/bin/bash

SOURCE_DIR="/home/user/documents"
BACKUP_DIR="/backup"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="backup_${DATE}.tar.gz"

# Create backup
echo "Creating backup..."
if tar -czf "${BACKUP_DIR}/${BACKUP_NAME}" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")"; then
    echo "Backup created: ${BACKUP_DIR}/${BACKUP_NAME}"
    
    # Remove old backups (keep last 7)
    find "$BACKUP_DIR" -name "backup_*.tar.gz" -type f -mtime +7 -delete
else
    echo "Backup failed!" >&2
    exit 1
fi
```

## Resources

- [Bash Manual](https://www.gnu.org/software/bash/manual/)
- [ShellCheck](https://www.shellcheck.net/) - Script analysis tool
- [Bash Pitfalls](http://mywiki.wooledge.org/BashPitfalls)
- [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/)

## Contributing

Feel free to contribute examples, improvements, or corrections to this guide!