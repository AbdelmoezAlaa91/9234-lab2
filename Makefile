DIR ?= dir
MALICIOUS_DIR ?= malicious_dir
INTERVAL ?= 5

.PHONY: all run-daemon run-restore permissions create_dirs clean help

all: run-daemon

create_dirs:
	@mkdir -p $(DIR) $(MALICIOUS_DIR)

permissions:
	@chmod +x antivirusd.sh restore.sh antivirus-cron.sh

run-daemon: create_dirs permissions
	@echo "Starting antivirus daemon..."
	./antivirusd.sh $(DIR) $(MALICIOUS_DIR) $(INTERVAL)

run-restore: create_dirs permissions
	@echo "Starting interactive restore tool..."
	./restore.sh $(DIR) $(MALICIOUS_DIR)

clean:
	@echo "Cleaning temporary tracking files..."
	rm -f directory-info.last directory-info.new cron.log
	@echo "Cleanup finished."

help:
	@echo "Usage:"
	@echo "  make              : Create dirs, set permissions, and run antivirusd.sh"
	@echo "  make run-daemon   : Run antivirusd.sh with required arguments"
	@echo "  make run-restore  : Run restore.sh with required arguments"
	@echo "  make clean        : Remove temporary tracking files"
