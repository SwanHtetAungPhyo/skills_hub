# Unix System Administration Guide

A comprehensive guide to Unix system administration, commands, and best practices for system administrators and power users.

## Table of Contents

- [Introduction](#introduction)
- [System Architecture](#system-architecture)
- [Essential Commands](#essential-commands)
- [File System Management](#file-system-management)
- [Process Management](#process-management)
- [User and Group Management](#user-and-group-management)
- [Network Administration](#network-administration)
- [System Monitoring](#system-monitoring)
- [Security](#security)
- [Backup and Recovery](#backup-and-recovery)
- [Performance Tuning](#performance-tuning)
- [Troubleshooting](#troubleshooting)

## Introduction

Unix is a family of multitasking, multiuser computer operating systems that derive from the original AT&T Unix. This guide covers system administration tasks across various Unix-like systems including Linux, BSD, and traditional Unix variants.

### Key Principles

- **Everything is a file** - Devices, processes, and system information are represented as files
- **Small, focused tools** - Programs do one thing well and can be combined
- **Text-based configuration** - Human-readable configuration files
- **Hierarchical file system** - Organized directory structure starting from root (/)

## System Architecture

### Directory Structure

```
/                   # Root directory
├── bin/           # Essential user binaries
├── boot/          # Boot loader files
├── dev/           # Device files
├── etc/           # System configuration files
├── home/          # User home directories
├── lib/           # Shared libraries
├── media/         # Removable media mount points
├── mnt/           # Temporary mount points
├── opt/           # Optional software packages
├── proc/          # Process and kernel information
├── root/          # Root user's home directory
├── run/           # Runtime data
├── sbin/          # System binaries
├── srv/           # Service data
├── sys/           # System information
├── tmp/           # Temporary files
├── usr/           # User programs and data
└── var/           # Variable data (logs, caches)
```

### System Boot Process

1. **BIOS/UEFI** - Hardware initialization
2. **Boot Loader** - GRUB, LILO loads kernel
3. **Kernel** - Hardware detection and initialization
4. **Init System** - SystemD, SysV, or Upstart
5. **Runlevels/Targets** - Start system services
6. **Login** - User authentication

## Essential Commands

### File Operations

```bash
# List files and directories
ls -la                    # Detailed listing with hidden files
ls -lh                    # Human-readable file sizes
ls -lt                    # Sort by modification time

# Copy, move, delete
cp source destination     # Copy file
cp -r dir1 dir2          # Copy directory recursively
mv oldname newname       # Move/rename file
rm file                  # Delete file
rm -rf directory         # Delete directory recursively

# Create directories
mkdir directory          # Create directory
mkdir -p path/to/dir     # Create parent directories

# File permissions
chmod 755 file           # rwxr-xr-x
chmod u+x file           # Add execute for user
chown user:group file    # Change ownership
```

### Text Processing

```bash
# View file contents
cat file.txt             # Display entire file
less file.txt            # Page through file
head -n 10 file.txt      # First 10 lines
tail -n 10 file.txt      # Last 10 lines
tail -f logfile          # Follow file changes

# Search and filter
grep "pattern" file      # Search for pattern
grep -r "pattern" dir/   # Recursive search
find /path -name "*.txt" # Find files by name
find /path -type f -mtime -7  # Files modified in last 7 days

# Text manipulation
sort file.txt            # Sort lines
uniq file.txt            # Remove duplicates
wc -l file.txt           # Count lines
cut -d: -f1 /etc/passwd  # Extract first field
sed 's/old/new/g' file   # Replace text
awk '{print $1}' file    # Print first column
```

### System Information

```bash
# System overview
uname -a                 # System information
hostname                 # System hostname
uptime                   # System uptime and load
whoami                   # Current user
id                       # User and group IDs
date                     # Current date and time

# Hardware information
lscpu                    # CPU information
lsmem                    # Memory information
lsblk                    # Block devices
lspci                    # PCI devices
lsusb                    # USB devices
dmidecode                # Hardware details from BIOS
```

## File System Management

### Disk Management

```bash
# View disk usage
df -h                    # Disk space usage
du -sh directory         # Directory size
du -h --max-depth=1      # Size of subdirectories

# Partition management
fdisk -l                 # List partitions
parted /dev/sda print    # Partition information
lsblk                    # Block device tree

# Mount/unmount filesystems
mount /dev/sda1 /mnt     # Mount filesystem
umount /mnt              # Unmount filesystem
mount -a                 # Mount all filesystems in /etc/fstab
```

### File System Check and Repair

```bash
# Check filesystem
fsck /dev/sda1           # Check and repair filesystem
fsck -f /dev/sda1        # Force check
e2fsck /dev/sda1         # Check ext2/3/4 filesystem

# Create filesystems
mkfs.ext4 /dev/sda1      # Create ext4 filesystem
mkfs.xfs /dev/sda1       # Create XFS filesystem
mkswap /dev/sda2         # Create swap filesystem
```

### /etc/fstab Configuration

```bash
# /etc/fstab format: device mountpoint fstype options dump pass
/dev/sda1    /           ext4    defaults        1  1
/dev/sda2    /home       ext4    defaults        1  2
/dev/sda3    swap        swap    defaults        0  0
tmpfs        /tmp        tmpfs   defaults,nodev,nosuid  0  0
```

## Process Management

### Process Monitoring

```bash
# View processes
ps aux                   # All processes
ps -ef                   # Process tree format
ps -u username           # Processes by user
pstree                   # Process tree

# Real-time monitoring
top                      # Interactive process viewer
htop                     # Enhanced process viewer
atop                     # Advanced system monitor
```

### Process Control

```bash
# Job control
jobs                     # List active jobs
bg %1                    # Send job to background
fg %1                    # Bring job to foreground
nohup command &          # Run command immune to hangups

# Kill processes
kill PID                 # Terminate process
kill -9 PID              # Force kill
killall process_name     # Kill by name
pkill -f pattern         # Kill by command pattern

# Process priority
nice -n 10 command       # Run with lower priority
renice 5 PID             # Change process priority
```

### System Services

```bash
# SystemD (modern Linux)
systemctl start service      # Start service
systemctl stop service       # Stop service
systemctl restart service    # Restart service
systemctl enable service     # Enable at boot
systemctl disable service    # Disable at boot
systemctl status service     # Service status
systemctl list-units        # List all units

# SysV Init (traditional)
service httpd start          # Start service
/etc/init.d/httpd start     # Alternative syntax
chkconfig httpd on          # Enable at boot
```

## User and Group Management

### User Management

```bash
# Create users
useradd username             # Create user
useradd -m -s /bin/bash user # Create with home directory and shell
passwd username              # Set password

# Modify users
usermod -aG group username   # Add user to group
usermod -s /bin/zsh username # Change shell
usermod -l newname oldname   # Rename user

# Delete users
userdel username             # Delete user
userdel -r username          # Delete user and home directory

# User information
finger username              # User information
last                        # Login history
w                           # Currently logged in users
who                         # Who is logged in
```

### Group Management

```bash
# Group operations
groupadd groupname          # Create group
groupdel groupname          # Delete group
groups username             # Show user's groups
getent group groupname      # Group information

# Configuration files
/etc/passwd                 # User accounts
/etc/shadow                 # Password hashes
/etc/group                  # Group definitions
/etc/gshadow               # Group passwords
```

### Sudo Configuration

```bash
# Edit sudoers file
visudo                      # Safe editing of /etc/sudoers

# Example sudoers entries
user ALL=(ALL) ALL          # Full sudo access
user ALL=(ALL) NOPASSWD: ALL  # No password required
%wheel ALL=(ALL) ALL        # Group-based access
user ALL=(root) /usr/bin/systemctl  # Specific command only
```

## Network Administration

### Network Configuration

```bash
# Network interfaces
ip addr show                # Show IP addresses
ip route show               # Show routing table
ip link show                # Show network interfaces

# Traditional tools
ifconfig                    # Interface configuration
route -n                    # Routing table
netstat -rn                 # Routing table

# Configure interface
ip addr add 192.168.1.10/24 dev eth0    # Add IP address
ip route add default via 192.168.1.1    # Add default route
```

### Network Diagnostics

```bash
# Connectivity testing
ping hostname               # Test connectivity
traceroute hostname         # Trace packet route
mtr hostname               # Network diagnostic tool

# Port and service testing
telnet host port           # Test port connectivity
nc -zv host port           # Test port with netcat
nmap -p 1-1000 host        # Port scanning

# Network statistics
netstat -tuln              # Listening ports
netstat -i                 # Interface statistics
ss -tuln                   # Socket statistics (modern)
```

### Firewall Management

```bash
# iptables (traditional)
iptables -L                # List rules
iptables -A INPUT -p tcp --dport 22 -j ACCEPT  # Allow SSH
iptables -A INPUT -j DROP  # Default drop policy

# firewalld (modern)
firewall-cmd --list-all    # Show current configuration
firewall-cmd --add-port=80/tcp --permanent    # Open port
firewall-cmd --reload      # Reload configuration

# UFW (Ubuntu)
ufw enable                 # Enable firewall
ufw allow 22               # Allow SSH
ufw status                 # Show status
```

## System Monitoring

### Performance Monitoring

```bash
# CPU and memory
top                        # Process monitor
htop                       # Enhanced process monitor
sar -u 1 10               # CPU utilization
vmstat 1                   # Virtual memory statistics

# Disk I/O
iostat -x 1               # I/O statistics
iotop                     # I/O by process
df -h                     # Disk space
du -sh /var/log           # Directory usage

# Memory usage
free -h                   # Memory usage
cat /proc/meminfo         # Detailed memory info
pmap PID                  # Process memory map
```

### Log File Management

```bash
# System logs
/var/log/messages         # General system messages
/var/log/syslog          # System log (Debian/Ubuntu)
/var/log/secure          # Authentication log
/var/log/auth.log        # Authentication log (Debian/Ubuntu)
/var/log/kern.log        # Kernel messages

# Log viewing
journalctl               # SystemD journal
journalctl -f            # Follow journal
journalctl -u service    # Service-specific logs
tail -f /var/log/messages  # Follow traditional logs

# Log rotation
logrotate -d /etc/logrotate.conf  # Test rotation
logrotate -f /etc/logrotate.conf  # Force rotation
```

## Security

### File Permissions

```bash
# Permission types
r (4) - read
w (2) - write  
x (1) - execute

# Examples
chmod 644 file           # rw-r--r--
chmod 755 directory     # rwxr-xr-x
chmod u+s file          # Set SUID bit
chmod g+s directory     # Set SGID bit
chmod +t directory      # Set sticky bit
```

### Access Control Lists (ACL)

```bash
# View ACLs
getfacl file            # Show ACL permissions

# Set ACLs
setfacl -m u:user:rw file        # Grant user read/write
setfacl -m g:group:rx file       # Grant group read/execute
setfacl -x u:user file           # Remove user ACL
setfacl -b file                  # Remove all ACLs
```

### System Hardening

```bash
# Disable unused services
systemctl disable service
systemctl mask service

# Secure SSH
# Edit /etc/ssh/sshd_config:
PermitRootLogin no
PasswordAuthentication no
AllowUsers user1 user2

# File integrity monitoring
aide --init             # Initialize AIDE database
aide --check            # Check file integrity

# System updates
yum update              # RedHat/CentOS
apt update && apt upgrade  # Debian/Ubuntu
```

## Backup and Recovery

### Backup Strategies

```bash
# Full system backup with tar
tar -czf backup.tar.gz --exclude=/proc --exclude=/sys \
    --exclude=/dev --exclude=/run /

# Incremental backup with rsync
rsync -av --delete /home/ /backup/home/

# Database backup
mysqldump -u root -p database > backup.sql
pg_dump database > backup.sql

# LVM snapshots
lvcreate -L 1G -s -n snap /dev/vg/lv
mount /dev/vg/snap /mnt/snapshot
```

### Backup Automation

```bash
#!/bin/bash
# Daily backup script

BACKUP_DIR="/backup/$(date +%Y%m%d)"
SOURCE_DIRS="/home /etc /var/www"

mkdir -p "$BACKUP_DIR"

for dir in $SOURCE_DIRS; do
    if [ -d "$dir" ]; then
        tar -czf "$BACKUP_DIR/$(basename $dir).tar.gz" "$dir"
    fi
done

# Remove backups older than 30 days
find /backup -type d -mtime +30 -exec rm -rf {} \;
```

### Recovery Procedures

```bash
# Single user mode (recovery mode)
# Edit GRUB entry and add: single or init=/bin/bash

# Mount filesystem read-write
mount -o remount,rw /

# Reset root password
passwd root

# File system repair
fsck -y /dev/sda1

# Restore from backup
tar -xzf backup.tar.gz -C /restore/location
```

## Performance Tuning

### System Optimization

```bash
# Kernel parameters
echo 'vm.swappiness=10' >> /etc/sysctl.conf
echo 'net.core.rmem_max=134217728' >> /etc/sysctl.conf
sysctl -p                # Apply changes

# I/O scheduler
echo noop > /sys/block/sda/queue/scheduler

# CPU governor
echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
```

### Memory Management

```bash
# Clear caches
echo 1 > /proc/sys/vm/drop_caches  # Page cache
echo 2 > /proc/sys/vm/drop_caches  # Dentries and inodes
echo 3 > /proc/sys/vm/drop_caches  # All caches

# Swap management
swapon -s               # Show swap usage
swapoff /dev/sda2       # Disable swap
swapon /dev/sda2        # Enable swap
```

## Troubleshooting

### Common Issues

```bash
# High load average
top                     # Identify CPU-intensive processes
ps aux --sort=-%cpu     # Sort by CPU usage
iostat -x 1            # Check for I/O bottlenecks

# Out of disk space
df -h                  # Check disk usage
du -sh /* | sort -h    # Find large directories
lsof | grep deleted    # Find deleted files held open

# Network issues
ping gateway           # Test local connectivity
dig domain.com         # DNS resolution
netstat -tuln          # Check listening services
tcpdump -i eth0        # Packet capture
```

### System Recovery

```bash
# Boot from rescue media
# Mount root filesystem
mount /dev/sda1 /mnt
mount --bind /dev /mnt/dev
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys
chroot /mnt

# Reinstall bootloader
grub-install /dev/sda
update-grub

# Fix fstab errors
vi /etc/fstab
mount -a                # Test mount points
```

### Log Analysis

```bash
# Common log locations and analysis
grep "ERROR" /var/log/messages
grep "Failed" /var/log/secure
journalctl --since "1 hour ago" --priority=err

# System resource logs
dmesg | grep -i error
dmesg | grep -i memory
cat /proc/cpuinfo
cat /proc/meminfo
```

## Shell Scripting for System Administration

### System Information Script

```bash
#!/bin/bash

echo "=== System Health Check ==="
echo "Date: $(date)"
echo "Uptime: $(uptime -p)"
echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
echo "Memory Usage: $(free | grep Mem | awk '{printf "%.2f%%", $3/$2*100}')"
echo "Disk Usage:"
df -h | grep -E '^/dev' | awk '{print $6 ": " $5}'
echo "Top 5 Processes by CPU:"
ps aux --sort=-%cpu | head -6
```

### Log Monitoring Script

```bash
#!/bin/bash

LOGFILE="/var/log/messages"
ALERT_EMAIL="admin@company.com"
LAST_CHECK="/tmp/last_check"

if [ ! -f "$LAST_CHECK" ]; then
    touch "$LAST_CHECK"
fi

# Find new error entries since last check
NEW_ERRORS=$(find "$LOGFILE" -newer "$LAST_CHECK" -exec grep -i "error\|critical\|fatal" {} \;)

if [ -n "$NEW_ERRORS" ]; then
    echo "New errors found:" | mail -s "System Alert" "$ALERT_EMAIL"
    echo "$NEW_ERRORS" | mail -s "Error Details" "$ALERT_EMAIL"
fi

touch "$LAST_CHECK"
```

## Best Practices

### Security Best Practices

1. **Regular Updates** - Keep system and software updated
2. **Principle of Least Privilege** - Grant minimum necessary permissions
3. **Strong Passwords** - Enforce password policies
4. **SSH Hardening** - Disable root login, use key authentication
5. **Firewall Configuration** - Block unnecessary ports
6. **Log Monitoring** - Regular log review and alerting
7. **Backup Strategy** - Regular, tested backups

### Performance Best Practices

1. **Monitor Resources** - Regular performance monitoring
2. **Capacity Planning** - Plan for growth
3. **Optimize Services** - Disable unnecessary services
4. **Tune Kernel Parameters** - Optimize for workload
5. **Regular Maintenance** - Log rotation, cleanup tasks

### Configuration Management

1. **Version Control** - Track configuration changes
2. **Documentation** - Document system changes
3. **Standardization** - Consistent configurations
4. **Testing** - Test changes in non-production
5. **Automation** - Automate repetitive tasks

## Useful Resources

- [The Linux Documentation Project](https://tldp.org/)
- [Unix and Linux System Administration Handbook](https://admin.com/)
- [Red Hat System Administrator's Guide](https://access.redhat.com/documentation/)
- [Ubuntu Server Guide](https://ubuntu.com/server/docs)
- [FreeBSD Handbook](https://www.freebsd.org/doc/handbook/)
- [OpenBSD FAQ](https://www.openbsd.org/faq/)

## Contributing

Contributions to improve this guide are welcome! Please ensure any additions follow Unix/Linux best practices and are well-documented with examples.

---

*This guide serves as a comprehensive reference for Unix system administration. Always test commands in a safe environment before applying them to production systems.*