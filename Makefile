.PHONY: clean all launch showlab

ASM := acme

UNAME := $(shell uname)
ifeq ($(UNAME),Darwin)
	X64_BIN := x64
	X64 := /Applications/Vice64/x64.app/Contents/MacOS/$(X64_BIN)
	KILLALL := killall
endif
ifeq ($(UNAME),CYGWIN_NT-10.0)
	X64 := x64.exe
	X64_BIN := $(X64) # assuming this is on the path
	KILLALL := taskkill /f /im
endif

BUILDDIR := build
LABELS := $(BUILDDIR)/labels.txt

TARGET_PRG := $(BUILDDIR)/slither.prg

SRCS := $(wildcard code/*.asm)
DATA := data/slither_r.sid

all: $(TARGET_PRG) launch

$(TARGET_PRG): index.asm $(SRCS) $(DATA)
	acme -l $(LABELS) $<

launch: $(TARGET_PRG)
	$(KILLALL) $(X64_BIN) || true
	$(X64) $< &

showlab: $(TARGET_PRG)
	cat $(LABELS)

clean:
	rm -f $(LABELS) $(TARGET_PRG)
