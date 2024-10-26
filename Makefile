### Compile Options
# Compiler
COMPILER ?= gcc
# Compile Flags
COMPILE_FLAGS ?= 
# Linker 
LINKER ?= $(COMPILER)
LINK_FLAGS ?=

# If LIB_TYPE is dynamic, add -fPIC flag
ifeq ($(LIB_TYPE), dynamic)
	COMPILE_FLAGS += -fPIC
endif
# Header Folders
HEADER_FOLDERS ?= 
# Source Folders
SOURCE_FOLDERS ?= 

### Build Options
# Build Path
BUILD_PATH ?= build
# Header Path
HEADER_PATH ?= $(BUILD_PATH)/inc
# Object Path
OBJ_PATH ?= $(BUILD_PATH)/obj
# Library Path
LIB_PATH ?= $(BUILD_PATH)/lib
# Library Name
LIB_NAME ?= 
# Library Type
LIB_TYPE ?= 
# All Library Type
ALL_LIB_TYPE := static dynamic

### Files
# Source Files
SOURCE_FILES ?= $(wildcard $(patsubst %, %/*.c, $(SOURCE_FOLDERS)))

# Object Files
#OBJECT_FILES := $(patsubst %.c, $(OBJ_PATH)/%.o, $(notdir $(SOURCE_FILES)))
OBJECT_FILES ?= $(patsubst %.c,$(OBJ_PATH)/%.o, $(SOURCE_FILES))

####################################################################################


.PHONY: build check folder header library clean


### Build the library
build: check folder header library


### Check Env
check:
# Check if LIB_TYPE is set
ifndef LIB_TYPE
	$(error LIB_TYPE is not set)
endif
# Check LIB_TYPE
ifeq ($(if $(filter $(LIB_TYPE), $(ALL_LIB_TYPE)),yes,no), no)
	$(error LIB_TYPE is not valid. Please set LIB_TYPE to static or dynamic)
endif
# Check if LIB_NAME is set
ifndef LIB_NAME
	$(error LIB_NAME is not set)
endif


### Create Folders
folder:
	mkdir -p $(patsubst %, $(HEADER_PATH)/%, $(HEADER_FOLDERS)) $(patsubst %, $(OBJ_PATH)/%, $(SOURCE_FOLDERS)) $(LIB_PATH)
#             ^                                                 ^                                                ^ 
#             Create folders for header files                   Create folders for object files                  Create folders for library file

### Copy Header Files
header:
	$(foreach folder, $(HEADER_FOLDERS), cp $(folder)/*.h $(HEADER_PATH)/$(folder) && ) echo -n

### Build Library
library: $(OBJECT_FILES)
## Build Library
ifeq ($(LIB_TYPE), static)
	ar -rcs $(LIB_PATH)/$(LIB_NAME) $(OBJECT_FILES)
endif
ifeq ($(LIB_TYPE), dynamic)
	$(COMPILER) -shared -o $(LIB_PATH)/$(LIB_NAME) $(OBJECT_FILES) $(LINK_FLAGS)
endif


### Compile Object Files
$(OBJECT_FILES): %.o : $(filter $(patsubst %.o, \%/%.c, $(notdir %)), $(SOURCE_FILES))
	$(COMPILER) -c $(filter $(patsubst %.o, \%/%.c, $(notdir $@)), $(SOURCE_FILES)) -o $@ $(patsubst %, -I%, $(HEADER_FOLDERS)) $(COMPILE_FLAGS)

### Clean Build Files
OS = $(shell uname | tr -d '\n')
clean:
ifeq ($(OS), Linux)
	rm -rf $(HEADER_PATH) $(OBJ_PATH) $(LIB_PATH)
endif

info:
	@echo "Source files: $(SOURCE_FILES)"
	@echo "Object files: $(OBJECT_FILES)"