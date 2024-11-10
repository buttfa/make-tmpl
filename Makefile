### Compile Options
# Compiler
COMPILER ?=
# Compile Flags
COMPILE_FLAGS ?= 
# Linker 
LINKER ?= $(COMPILER)
# Linker Flags
LINK_FLAGS ?=


### Build Options
# Target Type
TARGET_TYPE ?= 
# Source Folders
SOURCE_FOLDERS ?= 
# Header Folders
HEADER_FOLDERS ?= 
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


####################################################################################

# All Target Type
ALL_TARGET_TYPE := app lib

# All Library Type
ALL_LIB_TYPE := static dynamic

# If LIB_TYPE is dynamic, add -fPIC flag
ifeq ($(LIB_TYPE), dynamic)
	COMPILE_FLAGS += -fPIC
endif

### Files
# Source Files
SOURCE_FILES ?= $(wildcard $(patsubst %, %/*.c, $(SOURCE_FOLDERS)))

# Object Files
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
#                                        ^
#                                        Copy header files to header path

### Build Library
library: $(OBJECT_FILES)
## Build Library
ifeq ($(LIB_TYPE), static)
	ar -rcs $(LIB_PATH)/$(LIB_NAME) $(OBJECT_FILES)
#   ^
#   Create static library
endif
ifeq ($(LIB_TYPE), dynamic)
	$(COMPILER) -shared -o $(LIB_PATH)/$(LIB_NAME) $(OBJECT_FILES) $(LINK_FLAGS)
#   ^
#   Create dynamic library
endif


### Compile Object Files
$(OBJECT_FILES): %.o : $(filter $(patsubst %.o, \%/%.c, $(notdir %)), $(SOURCE_FILES))
	$(COMPILER) -c $(filter $(patsubst %.o, \%/%.c, $(notdir $@)), $(SOURCE_FILES)) -o $@ $(patsubst %, -I%, $(HEADER_FOLDERS)) $(COMPILE_FLAGS)
#   ^
#   Compile object files

### Clean Build Files
clean:
	rm -rf $(HEADER_PATH) $(OBJ_PATH) $(LIB_PATH)
#   ^
#   Remove all build files on Linux

info:
	@echo "Source files: $(SOURCE_FILES)"
	@echo "Object files: $(OBJECT_FILES)"

copy-to-example:
	cp Makefile example/*/third_party/make-tmpl
	cp Makefile example/*/third_party/*/third_party/make-tmpl