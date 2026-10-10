# Antivirus

A lightweight Bash-based malware monitoring, quarantine, and recovery tool set.

## Overview & Folder Hierarchy

Directory structure of the repository:

```
9234-lab2/
├── antivirusd.sh        # Continuous monitoring daemon (loops with sleep interval)
├── restore.sh           # Interactive CLI tool to inspect and restore/delete quarantined files
├── antivirus-cron.sh    # Single-pass non-looping scanner designed for system cron scheduling
├── whitelist.txt        # Text file tracking user-restored clean files
├── Makefile             # Automation build file for permissions, execution, and cleanup
├── README.md            # Comprehensive project documentation
├── dir/                 # Default source directory monitored for threats
└── malicious_dir/       # Quarantine directory where flagged files are isolated
```

## Prerequisites & Installation on Ubuntu

This project requires a POSIX-compliant Linux environment (Ubuntu/Debian recommended) with `cron`, `make`, and `bash` installed.

### Installing Dependencies

If any of the required utilities are missing, run the following commands in your Ubuntu terminal:

```bash
# Update package lists
sudo apt update

# Install cron daemon, make, and bash
sudo apt install -y cron make bash
```

### Enabling and Verifying Services

Ensure the `cron` daemon service is active and enabled to start on boot:

```bash
# Start and enable cron service
sudo systemctl enable --now cron

# Verify cron status
sudo systemctl status cron
```

## Flagged Extensions & Keywords Definition

The detection rules for flagged file extensions and malicious content keywords are defined directly at the top of the scanning scripts (`antivirusd.sh` and `antivirus-cron.sh`):

### 1. Flagged Extensions
- **Variable:** `extension=("exe" "bat" "vbs" "scr" "ps1")`
- **Defined in:**
  * `antivirusd.sh`: Line 12
  * `antivirus-cron.sh`: Line 11

### 2. Flagged Content Keywords
- **Variable:** `content=("virus" "trojan" "malware" "worm" "ransomware")`
- **Defined in:**
  * `antivirusd.sh`: Line 13
  * `antivirus-cron.sh`: Line 12

## Whitelist Mechanism & False Positive Handling

To prevent restored files (false positives) from being repeatedly re-quarantined on subsequent scans, the system implements a persistent whitelist mechanism via `whitelist.txt`. This data persists across daemon restarts and system reboots.

### 1. How a File Gets Added to the Whitelist
When a user runs the interactive recovery tool (`restore.sh`) and selects option **1 (Restore)** for a quarantined file:
- The script extracts the file's base name using `basename`.
- It appends the filename to `whitelist.txt`:
  ```bash
  echo "$file_name" >> whitelist.txt
  ```
- The file is then successfully moved back from `malicious_dir` to the source directory (`dir`).

### 2. How the Daemon Checks the Whitelist During a Scan
During each scanning loop in `antivirusd.sh` (and single-pass runs in `antivirus-cron.sh`), before evaluating whether a file matches any restricted extensions or malicious keywords:
- The daemon checks `whitelist.txt`.
- If the current file's name is found inside the whitelist, the daemon completely skips that file, treating it as a safe false positive and leaving it untouched in the source directory even if it matches a flagged extension or keyword.

## Step-by-Step Instructions for Running Tools

### Setting Permissions

Before running the tools, ensure all scripts have execution permissions. You can set them using the `Makefile`:

```bash
make permissions
# Or simply: make
```

### 1. Running the Antivirus Daemon (`antivirusd.sh`)

The continuous daemon monitors the specified source directory, scans for malicious extensions or content keywords at every set interval, and moves threats to the quarantine folder (while skipping whitelisted items).

#### Option A: Execution via Makefile (Recommended)
```bash
make run-daemon
```
*(Automatically creates `dir` and `malicious_dir` if missing and runs `antivirusd.sh` with `dir`, `malicious_dir`, and an interval of 5 seconds).*

#### Option B: Manual CLI Execution
**Syntax:**
```bash
./antivirusd.sh <source_directory> <quarantine_directory> <interval_seconds>
```
**Example:**
```bash
./antivirusd.sh ./dir ./malicious_dir 5
```

### 2. Running the Interactive Restore Tool (`restore.sh`)

Allows administrators to review files inside the quarantine directory and choose an interactive action for each file.

#### Option A: Execution via Makefile
```bash
make run-restore
```

#### Option B: Manual CLI Execution
**Syntax:**
```bash
./restore.sh <source_directory> <quarantine_directory>
```
**Example:**
```bash
./restore.sh ./dir ./malicious_dir
```

**Interactive Options:**
1. **Restore:** Moves the file back to the source directory and adds its filename to `whitelist.txt` to prevent re-quarantining.
2. **Delete:** Permanently removes the file from the quarantine directory.
3. **Skip:** Ignores the file and leaves it in quarantine.

### 3. Cleaning Temporary Artifacts

To remove temporary tracking files (`directory-info.last`, `directory-info.new`, etc.):

```bash
make clean
```

## Cron Job Automation Guide (Bonus Task)

The `antivirus-cron.sh` script executes a single scanning pass without an infinite loop or `sleep` delay, relying on Linux `cron` for automated scheduling.

### Prerequisites for Cron Execution

1. **System Service:** Ensure `cron` daemon is running (`sudo systemctl status cron`).
2. **Execution Permissions:** Ensure `chmod +x antivirus-cron.sh` is applied.
3. **Absolute Paths:** `cron` runs in an isolated environment and does not recognize relative paths (`./`). Always use full absolute paths. You can find your current directory's absolute path using the `pwd` command.

### Step-by-Step Manual to Configure Cron (Every 1 Minute at Second 23)

Standard `cron` evaluates expressions at the top of every minute (00 seconds). To execute precisely at second 23, a prepended delay using `sleep 23` is incorporated.

1. Open the crontab editor in terminal:
   ```bash
   crontab -e
   ```

2. Select `/bin/nano` (Option `1`) if prompted.

3. Append the following line at the end of the file (replace `/ABSOLUTE/PATH/TO/PROJECT` with your actual system path):
   ```cron
   * * * * * sleep 23 && /ABSOLUTE/PATH/TO/PROJECT/antivirus-cron.sh /ABSOLUTE/PATH/TO/PROJECT/dir /ABSOLUTE/PATH/TO/PROJECT/malicious_dir
   ```
   * **Example:**
   ```cron
   * * * * * sleep 23 && /home/moez/9234-lab2/antivirus-cron.sh /home/moez/9234-lab2/dir /home/moez/9234-lab2/malicious_dir
   ```

4. Save and exit (`Ctrl + O` -> `Enter` -> `Ctrl + X`).

5. Verify the active cron job:
   ```bash
   crontab -l
   ```

### Cron Schedule Expression: Every 3rd Friday of the Month at 12:31 AM

To configure a scan that runs **every 3rd Friday of the month at 12:31 AM**, use the following cron expression:

```cron
31 0 15-21 * 5
```

#### Detailed Breakdown:

| Field | Value | Description |
| :--- | :--- | :--- |
| **Minute** | `31` | At minute 31 |
| **Hour** | `0` | At 12:00 AM (Midnight / Hour 0) |
| **Day of Month** | `15-21` | Days 15 through 21 (The 3rd Friday of any month always lands between the 15th and 21st) |
| **Month** | `*` | Every month |
| **Day of Week** | `5` | Friday (5 represents Friday in crontab syntax) |

#### Full Crontab Command Example:
```cron
31 0 15-21 * 5 /ABSOLUTE/PATH/TO/PROJECT/antivirus-cron.sh /ABSOLUTE/PATH/TO/PROJECT/dir /ABSOLUTE/PATH/TO/PROJECT/malicious_dir
```
- **Example:**
```cron
31 0 15-21 * 5 /home/moez/9234-lab2/antivirus-cron.sh /home/moez/9234-lab2/dir /home/moez/9234-lab2/malicious_dir
```
