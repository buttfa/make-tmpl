### Compile Options
# Language
LANGUAGE?=c
# Compiler
COMPILER?=
# Compile Flags
COMPILE_FLAGS?=
# Linker 
LINKER?=
# Linker Flags
LINK_FLAGS?=
# Library Files
LIBRARY_FILES?=


### Build Options
# Target Type
TARGET_TYPE?=
# Source Folders
SOURCE_FOLDERS?=
C_SOURCE_FILES?=
CPP_SOURCE_FILES?=
# Header Folders
HEADER_FOLDERS?=
# Build Path
BUILD_PATH?=build
# Header Path
HEADER_PATH?=$(BUILD_PATH)/inc
# Object Path
OBJ_PATH?=$(BUILD_PATH)/obj
# Library Path
LIB_PATH?=$(BUILD_PATH)/lib
# Library Name
LIB_NAME?=
# Library Type
LIB_TYPE?=
# App path
APP_PATH?=


####################################################################################

# All Language Type
ALL_LANGUAGE := c cpp

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
C_SOURCE_FILES += $(wildcard $(patsubst %, %/*.c, $(SOURCE_FOLDERS)))
SOURCE_FILES += $(C_SOURCE_FILES)
ifeq ($(LANGUAGE), cpp)
    CPP_SOURCE_FILES += $(wildcard $(patsubst %, %/*.cpp, $(SOURCE_FOLDERS)))
	SOURCE_FILES += $(CPP_SOURCE_FILES)
endif



# Object Files
OBJECT_FILES += $(patsubst %.c,$(OBJ_PATH)/%.o, $(C_SOURCE_FILES)) 
ifeq ($(LANGUAGE), cpp)
	OBJECT_FILES += $(patsubst %.cpp,$(OBJ_PATH)/%.o, $(CPP_SOURCE_FILES))
endif

####################################################################################


.PHONY: build check folder header library clean


### Build the library
build: check folder header library application


### Check Env
check:
## Check target type
# Check if TARGET_TYPE is set
ifndef TARGET_TYPE
	$(error TARGET_TYPE is not set)
endif
# Check TARGET_TYPE
ifeq ($(if $(filter $(TARGET_TYPE), $(ALL_TARGET_TYPE)),yes,no), no)
	$(error TARGET_TYPE is not valid. Please set TARGET_TYPE to app or lib)
endif

## Check application information
ifeq ($(TARGET_TYPE), app)
#	Check if APP_NAME is set
ifndef APP_NAME
	$(error APP_NAME is not set)
endif
endif

## Check library information
# Check if LIB_TYPE is set
ifeq ($(TARGET_TYPE), lib)
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
endif


### Create Folders
folder:
	mkdir -p $(BUILD_PATH) $(patsubst %, $(OBJ_PATH)/%, $(SOURCE_FOLDERS))
#                          ^
#                          Create folders for object files
ifeq ($(TARGET_TYPE), lib)
	mkdir -p $(patsubst %, $(HEADER_PATH)/%, $(HEADER_FOLDERS)) $(LIB_PATH)
endif
#             ^                                                 ^
#             Create folders for header files                   Create folders for library file

### Copy Header Files
header:
ifeq  ($(TARGET_TYPE), lib)
	$(foreach folder, $(HEADER_FOLDERS), cp $(folder)/*.h $(HEADER_PATH)/$(folder) 2>NULL || true && ) rm -rf NULL || true
endif
#                                        ^
#                                        Copy header files to header path


### Build Application
application: $(OBJECT_FILES)
ifeq ($(TARGET_TYPE), app)
	$(LINKER) -o $(APP_PATH)/$(APP_NAME) $(OBJECT_FILES) $(LIBRARY_FILES) $(LINK_FLAGS)
endif

### Build Library
library: $(OBJECT_FILES)
ifeq ($(TARGET_TYPE), lib)
ifeq ($(LIB_TYPE), static)
	ar -rcs $(LIB_PATH)/$(LIB_NAME) $(OBJECT_FILES)
#   ^
#   Create static library
endif
ifeq ($(LIB_TYPE), dynamic)
	$(COMPILER) -shared -o $(LIB_PATH)/$(LIB_NAME) $(OBJECT_FILES) $(LIBRARY_FILES) $(LINK_FLAGS)
#   ^
#   Create dynamic library
endif
endif


### Compile Object Files
$(OBJ_PATH)/%.o : %.c
	$(COMPILER) -c $< -o $@ $(patsubst %, -I%, $(HEADER_FOLDERS)) $(COMPILE_FLAGS)
ifeq ($(LANGUAGE), cpp)
$(OBJ_PATH)/%.o : %.cpp
	$(COMPILER) -c $< -o $@ $(patsubst %, -I%, $(HEADER_FOLDERS)) $(COMPILE_FLAGS)
endif
#   ^
#   Compile object files

### Clean Build Files
clean:
	rm -rf $(BUILD_PATH) $(HEADER_PATH) $(OBJ_PATH) $(LIB_PATH)
#   ^
#   Remove all build files

info:
	@echo "Source files: $(SOURCE_FILES)"
	@echo "Object files: $(OBJECT_FILES)"
