.PHONY: clean all launch showlab

ASM := acme

UNAME := $(shell uname)
ifeq ($(UNAME),Darwin)
	X64 := x64
	KILLALL := killall
endif
ifeq ($(UNAME),CYGWIN_NT-10.0)
	X64 := x64.exe
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
	$(KILLALL) $(X64) || true
	$(X64) $< &

showlab: $(TARGET_PRG)
	cat $(LABELS)

clean:
	rm -f $(LABELS) $(TARGET_PRG)
