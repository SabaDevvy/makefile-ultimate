# =============================================================================
# Makefile Ultimate
# Copyright (c) 2025 (@SabaDevvy)
# https://github.com/SabaDevvy/makefile-ultimate
#
# Features:
# - Colorful outputs with clean formatting
# - Debug builds with AddressSanitizer
# - Valgrind integration (native and Docker)
# - Submodule management
# =============================================================================

# ===== Colors =====

RST					= \033[0m
BLD					= \033[1m
ERS					= \033[K

RED					= \033[0;31m
GRN					= \033[0;32m
YLW					= \033[0;33m
BLU					= \033[0;34m
MAG					= \033[0;35m
CYN					= \033[0;36m
WHT					= \033[0;37m

REDB				= \033[0;91m
GRNB				= \033[0;92m
YLWB				= \033[0;93m
BLUB				= \033[0;94m
CYNB				= \033[0;96m


# ===== Git settings =====

GITHUB_USER			:= <...> #Github username
GITHUB_URL			:= git@github.com:$(GITHUB_USER)/


# ===== Make settings and machine info =====

LOG_TIME			= $$(date "+%H:%M:%S")
UNAME_S				:= $(shell uname -s)
UNAME_M				:= $(shell uname -m)
IS_LINUX			:= $(filter Linux,$(UNAME_S))

JOBS				:= $(shell nproc 2>/dev/null || echo 2)

ifeq ($(filter --jobserver-fds=% -j%,$(MAKEFLAGS)),)
  ifeq ($(MAKELEVEL), 0)
    MAKEFLAGS += -j$(JOBS)
  endif
endif

ifndef VERBOSE
	MAKEFLAGS += -s
	MAKEFLAGS += --no-print-directory
endif


# ===== Project Info =====

PROJECT				= <...>
PROJECT_BONUS		= <...>

NAME				= $(PROJECT)
NAME_DEBUG			= $(addsuffix _debug.exe, $(PROJECT))
NAME_DEBUG_VAL		= $(addsuffix _debug_val.exe, $(PROJECT))
ASAN_LOGS			= $(addsuffix .dSYM, $(NAME_DEBUG))

NAME_BONUS			= $(PROJECT_BONUS)
NAME_DEBUG_BONUS	= $(addsuffix _debug.exe, $(PROJECT_BONUS))
NAME_DEBUG_VAL_BONUS= $(addsuffix _debug_val.exe, $(PROJECT_BONUS))
ASAN_LOGS_BONUS		= $(addsuffix .dSYM, $(NAME_DEBUG_BONUS))



# ===== Libraries Info =====
# LIBS_PRIVATE if you don't use submodules, else LIBS_SUBMODULE. LIBS_EXTERNAL = external libraries.

LIBS_PRIVATE		:= <...>
LIBS_SUBMODULE		:= <...>
LIBS_EXTERNAL		:= <...>
LIBS				:= $(LIBS_SUBMODULE) $(LIBS_PRIVATE) $(LIBS_EXTERNAL)
LIBS_CLEAN			:= $(strip $(LIBS))


# ===== Compile settings =====

CC					= cc
CFLAGS				= -Wall -Wextra -Werror -Iincludes
DEBUG_FLAGS			= -O0 -gdwarf-4 -fno-omit-frame-pointer
SANITIZE_COMPILE	= -fsanitize=address -fsanitize=undefined -fsanitize=signed-integer-overflow # -fsanitize=thread
SANITIZE_LINK		= -fsanitize=address -fsanitize=undefined -fsanitize=signed-integer-overflow # -fsanitize=thread
RM					= rm -rf

ifdef DEBUG
CFLAGS				+= -DDEBUG
endif


# ===== Directories =====

SRCS_DIR			:= src/
OBJS_DIR 			:= objs/
OBJS_DIRS			= $(sort $(dir $(OBJS)))
DEBUG_DIR			= debug/
DOCKER_DIR			= debug/docker/
LIBS_DIR			:= libraries/
LIBS_DIRS			:= $(addprefix $(LIBS_DIR), $(addsuffix /, $(LIBS)))

OBJS_DEBUG_DIR		= debug/objs/
OBJS_DOCKER_DIR		= debug/docker/objs/


# ===== Compile Info =====

SRCS				:= $(shell find src -type f -name "*.c")

OBJS				:= $(SRCS:$(SRCS_DIR)%.c=$(OBJS_DIR)%.o)
OBJS_DEBUG			:= $(SRCS:$(SRCS_DIR)%.c=$(OBJS_DEBUG_DIR)%.o)
OBJS_DOCKER			:= $(SRCS:$(SRCS_DIR)%.c=$(OBJS_DOCKER_DIR)%.o)

OBJS_BONUS			:= <...>
OBJS_DEBUG_BONUS	:= <...>
OBJS_DOCKER_BONUS	:= <...>

DEPS				:= $(wildcard includes/*.h)

LIBS_LINKS			:= $(addprefix -L, $(LIBS_DIRS)) $(addprefix -l, $(subst lib,,$(LIBS)))
LIBS_LINKS_DOCKER	:= $(addprefix -L, $(DOCKER_DIR)) $(addprefix -l, $(subst lib,,$(addsuffix _docker,$(LIBS))))

ifdef BONUS
	NAME_DEBUG		= $(NAME_DEBUG_BONUS)
	NAME_DEBUG_VAL	= $(NAME_DEBUG_VAL_BONUS)
	OBJS_DEBUG		= $(OBJS_DEBUG_BONUS)
	OBJS_DOCKER		= $(OBJS_DOCKER_BONUS)
	ASAN_LOGS		= $(ASAN_LOGS_BONUS)
endif


# # ===== Includes =====
#
# INCLUDES_DIR		:= includes/
# INCLUDES_DIRS		:= $(INCLUDES_DIR) $(addsuffix $(INCLUDES_DIR), $(LIBS_DIRS))
# vpath %.h $(INCLUDES_DIRS)
# CFLAGS				+= $(addprefix -I, $(INCLUDES_DIRS))
# $(info $(INCLUDES_DIRS))


# ===== Log Functions =====

define log_msg
	printf '[%s]$(1)[$(PROJECT)]	[%s]	%b$(RST)\n' "$(LOG_TIME)" "$(2)" "$(3)"
endef

define log_ers
	@printf '$(ERS)[%s]$(1)[$(PROJECT)]	[%s]	%b$(RST)\r' "$(LOG_TIME)" "$(2)" "$(3)"
endef

define log_obg_det
	@printf "[%s]$(YLW)[$(PROJECT)]	[COMPILE]	Compiling $(YLWB)%-42s$(YLW) in %s$(RST)\n" "$(LOG_TIME)" "$(1)" "$(realpath $(dir $(2)))"
endef


# ===== RULES =====

all: validate_env build-libs
	@mkdir -p $(sort $(dir $(OBJS)))
	$(MAKE) $(NAME)

bonus: validate_env build-libs
	@mkdir -p $(sort $(dir $(OBJS)))
	$(MAKE) $(NAME_BONUS)

$(NAME): $(OBJS)
	$(call log_ers,$(YLW),COMPILE,[$(NAME)] src files successfully compiled\n)
	$(call log_msg,$(YLWB),COMPILE,Compiling exe [$(NAME)]...)
	$(CC) $(CFLAGS) $(OBJS) $(LIBS_LINKS) -o $(NAME)
	$(call log_msg,$(GRNB),SUCCESS,Exe [$(NAME)] successfully compiled)

$(NAME_BONUS): $(OBJS_BONUS)
	$(call log_ers,$(YLW),COMPILE,[$(NAME_BONUS)] src files successfully compiled)
	$(call log_msg,$(YLWB),COMPILE,Compiling exe [$(NAME_BONUS)]...)
	$(CC) $(CFLAGS) $(OBJS_BONUS) $(LIBS_LINKS) -o $(NAME_BONUS)
	$(call log_msg,$(GRNB),SUCCESS,Exe [$(NAME_BONUS)] successfully compiled!)

$(OBJS_DIR)%.o: $(SRCS_DIR)%.c $(DEPS)
ifeq ($(DETAILS),1)
	$(call log_obg_det,$<,$@)
else
	$(call log_ers,$(YLW),COMPILE,Compiling $(YLWB)$<$)
endif
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	$(call log_msg,$(RED),CLEAN,	Cleaning [$(NAME)] object files...)
	$(RM) $(OBJS_DIR)

fclean: clean
	$(call log_msg,$(REDB),FCLEAN,Full cleaning: Removing [$(NAME)]...)
	$(RM) $(NAME) $(NAME_BONUS) $(DEBUG_DIR)

re:
	$(MAKE) fclean
	$(MAKE) all


# ===== Environment =====

validate_env: # NAME=$(...)
	$(call log_msg,$(BLU),INFO,	Checking [$(NAME)] environment...)
	# Check if required libs paths exist
	@for library in $(LIBS); do \
		if [ ! -d "$(LIBS_DIR)$$library" ]; then \
			$(call log_msg,$(REDB),ERROR,	$$library directory not found!); \
			$(call log_msg,$(YLW),INFO,	-> Run: [$(YLWB)make clone_libs / make update_submodules$(YLW)] and import external libraries if there are any.) ; \
			exit 1 ; \
		fi; \
	done
	# Check for outdated or uninitialized submodules
	@if git submodule status --recursive | grep '^[+-]' > /tmp/submodule_issues; then \
		$(call log_msg,$(REDB),ERROR,	Some submodules are outdated or not initialized!); \
		while read -r line; do \
			submodule=$$(echo $$line | awk '{print $$2}'); \
			submodule_name=$$(basename $$submodule); \
			if echo "$$line" | grep -q '^+'; then \
				$(call log_msg,$(YLW),WARNING,Submodule $$submodule is not on tracked commit.); \
				$(call log_msg,$(YLW),INFO,					-> Git add and commit to update submodule commit, or run [$(YLWB)make update_submodules$(YLW)] to set it back to tracked commit.); \
			elif echo "$$line" | grep -q '^-'; then \
				$(call log_msg,$(RED),ERROR,	Submodule $$submodule is not initialized!. Run: [$(YLWB)make clone_libs / make update_submodules$(RED)]); \
				exit 1; \
			fi; \
		done < /tmp/submodule_issues; \
		rm /tmp/submodule_issues; \
	fi
	# Checks uncommitted changes
	@for submodule in $(LIBS_SUBMODULE); do \
		if cd $(LIBS_DIR)$$submodule && git status --porcelain | grep -q .; then \
			$(call log_msg,$(YLW),WARNING,Detected changes in submodule [$(LIBS_DIR)$$submodule]. Remember to commit in modified submodules!); \
		fi; \
		cd $(CURDIR); \
	done
	$(call log_ers,$(GRN),SUCCESS,[$(NAME)] environment validated\n)

update_submodules:
	$(call log_msg,$(BLU),INFO,	Initializing/updating submodules [$(LIBS_SUBMODULE)]...)
	@git submodule update --init --recursive
	$(call log_msg,$(GRN),SUCCESS,All submodules are now initialized and up to date!)

clone_repos:
	@if [ -z "$(LIBS_PRIVATE)" ]; then \
		$(call log_msg,$(YLW),INFO,	No private libraries to clone!); \
	else \
		for library in $(LIBS_PRIVATE); do \
			$(call log_msg,$(BLU),INFO,	Cloning [$(BLUB)$$library$(BLU)] in $(LIBS_DIR)$$library); \
			git clone $(GITHUB_URL)$$library.git $(LIBS_DIR)$$library; \
		done; \
		$(call log_msg,$(GRN),SUCCESS,All needed private libraries have been cloned!); \
	fi

build-libs:
	@if [ -z "$(LIBS_CLEAN)" ]; then \
		$(call log_msg,$(YLW),INFO,	No libraries to build.); \
	else \
		$(call log_msg,$(BLUB),INFO,	Building libraries...); \
		for lib_dir in $(LIBS_DIRS); do \
			$(call log_msg,$(BLU),BUILD,	Building in $$lib_dir); \
			$(MAKE) -C $$lib_dir; \
		done; \
	fi

re-build-libs:
	@if [ -z "$(LIBS_CLEAN)" ]; then \
		$(call log_msg,$(YLW),INFO,	No libraries to rebuild.); \
	else \
		$(call log_msg,$(BLUB),INFO,	Rebuilding libraries...); \
		for lib_dir in $(LIBS_DIRS); do \
			$(call log_msg,$(BLU),	BUILD,Rebuilding in $$lib_dir); \
			$(MAKE) -C $$lib_dir re; \
		done; \
	fi

clean-deep:
	@if [ -z "$(LIBS_CLEAN)" ]; then \
		$(call log_msg,$(YLW),INFO,	No libraries to clean.); \
	else \
		$(call log_msg,$(REDB),DEEP CLEAN,Cleaning all dependent libraries: [$(LIBS)]...); \
		for lib_dir in $(LIBS_DIRS); do \
			$(call log_msg,$(RED),CLEAN,	Cleaning in $$lib_dir); \
			$(MAKE) -C $$lib_dir clean; \
		done; \
		$(MAKE) clean; \
	fi

fclean-deep:
	@if [ -z "$(LIBS_CLEAN)" ]; then \
		$(call log_msg,$(YLW),INFO,	No libraries to full clean.); \
	else \
		$(call log_msg,$(REDB),DEEP FCLEAN,Full Cleaning all dependent libraries: [$(LIBS)]...); \
		for lib_dir in $(LIBS_DIRS); do \
			$(call log_msg,$(RED),FCLEAN,Full cleaning in $$lib_dir); \
			$(MAKE) -C $$lib_dir fclean; \
		done; \
		$(MAKE) fclean; \
	fi

re-deep:
	@if [ -z "$(LIBS_CLEAN)" ]; then \
		$(call log_msg,$(YLW),INFO,	No libraries to Rebuild.); \
	else \
		$(call log_msg,$(BLUB),REBUILD,Completely rebuilding all libraries and project...); \
		for lib_dir in $(LIBS_DIRS); do \
			$(call log_msg,$(BLU),REBUILD,Rebuilding in $$lib_dir); \
			$(MAKE) -C $$lib_dir re; \
		done; \
		$(MAKE) re; \
	fi


# ===== Debug =====

ASAN_CHECK				= $(shell $(CC) -fsanitize=address -x c -c /dev/null -o /dev/null 2>/dev/null && echo "supported" || echo "not_supported")

debug:
	$(call log_msg,$(BLU),DEBUG,	Building debug version...)
	mkdir -p $(sort $(dir $(OBJS_DEBUG)))
	if [ "$(ASAN_CHECK)" = "supported" ]; then \
		$(call log_msg,$(GRN),INFO,	Address Sanitizer is supported and will be enabled); \
		$(MAKE) build-libs; \
		$(MAKE) --no-print-directory SANITIZE=yes debug-build; \
	else \
		$(call log_msg,$(YLW),WARNING,Address Sanitizer not enabled/supported, building with basic debug symbols); \
		$(MAKE) build-libs; \
		$(MAKE) --no-print-directory debug-build_no_asan; \
	fi

debug-build: $(OBJS_DEBUG)
	$(call log_ers,$(YLW),COMPILE,[$(NAME_DEBUG)] src files successfully compiled\n)
	$(call log_msg,$(YLWB),DEBUG,	Compiling [$(NAME_DEBUG)] exe...)
	$(CC) $(CFLAGS) $(DEBUG_FLAGS) $(SANITIZE_COMPILE) \
		$(OBJS_DEBUG) $(LIBS_LINKS) $(SANITIZE_LINK) -o $(NAME_DEBUG)
	$(call log_msg,$(GRNB),SUCCESS,Debug build complete with:)
	$(call log_msg,$(BLU),DEB-INFO,- Debug symbols enabled)
	$(call log_msg,$(BLU),DEB-INFO,- Address sanitizer active (detects memory issues))
	$(call log_msg,$(BLU),DEB-INFO,- Undefined behavior detection active)
	$(call log_msg,$(BLU),DEB-INFO,- Frame pointer preserved (for better backtraces))
	@mv -f $(NAME_DEBUG) $(ASAN_LOGS) ./$(DEBUG_DIR) 2>/dev/null || true
	$(call log_msg,$(BLU),INFO,	[$(NAME_DEBUG)] and [$(ASAN_LOGS)] in ./$(DEBUG_DIR))

debug-build_no_asan: $(OBJS_DEBUG) #OBJS_DEBUG=$(...) NAME_DEBUG=$(...) LIBS_LINKS=$(...)
	$(call log_ers,$(YLW),COMPILE,[$(NAME_DEBUG)] src files successfully compiled\n)
	$(call log_msg,$(YLWB),DEBUG,	Compiling [$(NAME_DEBUG)] exe without sanitizers...)
	$(CC) $(CFLAGS) $(DEBUG_FLAGS) $(OBJS_DEBUG) $(LIBS_LINKS) -o $(NAME_DEBUG)
	$(call log_msg,$(GRNB),SUCCESS,Debug build complete with basic debug symbols)
	$(call log_msg,$(BLU),DEB-INFO,[$(NAME_DEBUG)] in ./$(DEBUG_DIR))

$(OBJS_DEBUG_DIR)%.o: $(SRCS_DIR)%.c $(DEPS)
ifeq ($(DETAILS),1)
	$(call log_obg_det,$<,$@)
else
	$(call log_ers,$(YLW),COMPILE,Compiling $(YLWB)$<$)
endif
ifeq ($(SANITIZE),yes)
	$(CC) $(CFLAGS) $(DEBUG_FLAGS) $(SANITIZE_COMPILE) -c $< -o $@
else
	$(CC) $(CFLAGS) $(DEBUG_FLAGS) -c $< -o $@
endif

debug-run: debug
	$(call log_msg,$(BLUB),DEBUG-RUN,Running [$(NAME_DEBUG)] with sanitizers enabled...)
	./$(DEBUG_DIR)$(NAME_DEBUG) $(ARGS)

leak-check: debug
	$(call log_msg,$(BLU),DEBUG-RUN,Running [$(NAME_DEBUG)] with leak detection...)
	ASAN_OPTIONS=detect_leaks=1 ./$(DEBUG_DIR)$(NAME_DEBUG) $(ARGS)

debug-gdb: debug
	$(call log_msg,$(BLU),DEBUG-RUN,Starting [$(NAME_DEBUG)] with GDB session...)
	gdb -ex "set confirm off" -ex "b main" -ex "run" ./$(DEBUG_DIR)$(NAME_DEBUG) $(ARGS)

clean-debug:
	$(call log_msg,$(RED),CLEAN,	Cleaning debug object files...)
	$(RM) $(OBJS_DEBUG_DIR)

fclean-debug: clean-debug
	$(call log_msg,$(REDB),FCLEAN,Full cleaning: Removing [$(DEBUG_DIR)])
	$(RM) $(DEBUG_DIR) $(NAME_DEBUG) $(NAME_DEBUG_VAL) $(ASAN_LOGS)

re-debug:
	$(MAKE) fclean-debug
	$(MAKE) debug

debug-makeflags:
	@echo "[$(LOG_TIME)][$(PROJECT)]	MAKELEVEL: $(MAKELEVEL)"
	@echo "[$(LOG_TIME)][$(PROJECT)]	MAKEFLAGS: $(MAKEFLAGS)"
	@echo "[$(LOG_TIME)][$(PROJECT)]	Extracted -jN from MAKEFLAGS: $(filter -j%,$(MAKEFLAGS))"


# ===== Valgrind configuration =====

VALGRIND_IMAGE_NAME	:= valgrind-env
VALGRIND_PERS_CONT	:= valgrind-persistent
VALGRIND_REPORT		:= valgrind_report.txt
NAME_DEBUG_VAL_PATH	:= $(DEBUG_DIR)$(NAME_DEBUG_VAL)
REPORT_PATH			:= $(DEBUG_DIR)$(VALGRIND_REPORT)
VALGRIND_DOCKERFILE	:= $(DOCKER_DIR)Dockerfile

VALGRIND_FLAGS		:= --leak-check=full --show-leak-kinds=all --track-origins=yes --tool=memcheck


# ===== Valgrind rules =====

# Example: make valgrind ARGS='"1 2 3" "5 4 10"'(multiple argv); make valgrind ARGS="1 2 3 5 4 10" (unique argv)

valgrind:
ifeq ($(IS_LINUX),Linux)
	$(call log_msg,$(BLU),VALGRIND,Linux detected, running Valgrind natively...)
	$(MAKE) valgrind-native
else
	$(call log_msg,$(BLU),VALGRIND,Non-Linux OS detected, using Docker-based Valgrind...)
	@if [ "$(SLEEP)" = "1" ]; then \
		$(MAKE) valgrind-docker_sleep; \
	else \
		$(MAKE) valgrind-docker; \
	fi
endif
	$(call log_msg,$(GRN),SUCCESS,Valgrind analysis complete.)
	$(call log_msg,$(GRN),SUCCESS,Full report saved in $(REPORT_PATH))

valgrind-native:
	$(MAKE) validate_env NAME=$(NAME_DEBUG_VAL)
	$(call log_msg,$(BLUB),VALGRIND,Running Valgrind analysis natively...)
	@mkdir -p $(sort $(dir $(OBJS_DEBUG)))
	@if ! command -v valgrind >/dev/null 2>&1; then \
		$(call log_msg,$(RED),ERROR,	Valgrind is not installed. Please install it first.); \
		$(call log_msg,$(YLW),INFO,	Install with command: [sudo apt-get install valgrind]); \
		exit 1; \
	fi; \
	$(MAKE) build-libs
	$(MAKE) debug-build_no_asan \
	NAME_DEBUG=$(NAME_DEBUG_VAL)
	$(call log_msg,$(BLUB),VALGRIND,Running memory analysis with Valgrind...)
	echo '-----------------------------------------'
	@valgrind $(VALGRIND_FLAGS) --log-file=$(VALGRIND_REPORT) \
		./$(NAME_DEBUG_VAL) $(ARGS)
	@echo "\n-----------------------------------------"
	@mv -f $(NAME_DEBUG_VAL) ./$(DEBUG_DIR) 2>/dev/null
	$(MAKE) process-valgrind-report REPORT_PATH=$(VALGRIND_REPORT)
	@mv -f $(NAME_DEBUG_VAL) $(VALGRIND_REPORT) ./$(DEBUG_DIR) 2>/dev/null || true

valgrind-docker: valgrind-docker-setup
	$(call log_msg,$(BLUB),INFO,	Running Valgrind analysis inside docker container...)
	@docker run --rm \
		-v $(CURDIR):/app \
		-w /app \
		$(VALGRIND_IMAGE_NAME) \
		/bin/bash -c " \
			export MAKE=/usr/bin/make && \
			echo -e '[$(LOG_TIME)]$(CYNB)[$(PROJECT)]	[DOCKER]	Building debug version inside docker container...$(RST)' && \
			\$$MAKE build-docker_libs DETAILS=$(DETAILS) && \
			\$$MAKE debug-build_no_asan DETAILS=$(DETAILS) \
			OBJS_DEBUG=\"$(OBJS_DOCKER)\" \
			OBJS_DEBUG_DIR=\"$(OBJS_DOCKER_DIR)\" \
			NAME_DEBUG=\"$(NAME_DEBUG_VAL)\" \
			LIBS_LINKS=\"$(LIBS_LINKS_DOCKER)\" \
			ASAN_CHECK=\"not_supported\" && \
			SANITIZE=\"no\" && \
			echo -e '[$(LOG_TIME)]$(CYN)[$(PROJECT)]	[DOCKER]	Checking for executable...$(RST)'; \
			if [ ! -f \"$(NAME_DEBUG_VAL)\" ]; then \
				echo -e '[$(LOG_TIME)]$(RED)[$(PROJECT)]	[DOCK-ERROR]	Debug executable not found. Something went wrong during compilation...$(RST)'; \
				exit 1; \
			fi; \
			echo -e '[$(LOG_TIME)]$(CYNB)[$(PROJECT)]	[DOCK-INFO]	Valgrind build successfully compiled in docker container!$(RST)' && \
			echo -e '[$(LOG_TIME)]$(CYNB)[$(PROJECT)]	[DOCK-RUN]	Running Valgrind analysis in docker container...$(RST)' && \
			echo -e '-----------------------------------------' && \
			valgrind $(VALGRIND_FLAGS) --log-file=\"/app/$(VALGRIND_REPORT)\" \
			\"/app/$(NAME_DEBUG_VAL)\" \"$(ARGS)\" ; \
			echo -e '\n-----------------------------------------'; \
			mv -f \"$(NAME_DEBUG_VAL)\" \"./$(DEBUG_DIR)\" 2>/dev/null "
			$(MAKE) process-valgrind-report REPORT_PATH=$(VALGRIND_REPORT)
			@mv -f $(NAME_DEBUG_VAL) $(VALGRIND_REPORT) ./$(DEBUG_DIR) 2>/dev/null || true

valgrind-docker_sleep: valgrind-docker-setup valgrind-container-start
	$(call log_msg,$(BLUB),INFO,	Running Valgrind analysis inside persistent docker container...)
	@docker exec $(VALGRIND_PERS_CONT) \
		/bin/bash -c " \
			export MAKE=/usr/bin/make && \
			echo -e '[$(LOG_TIME)]$(CYNB)[$(PROJECT)]	[DOCK-INFO]	Building debug version inside docker container...$(RST)' && \
			\$$MAKE build-docker_libs DETAILS=$(DETAILS) && \
			\$$MAKE debug-build_no_asan DETAILS=$(DETAILS) \
			OBJS_DEBUG=\"$(OBJS_DOCKER)\" \
			OBJS_DEBUG_DIR=\"$(OBJS_DOCKER_DIR)\" \
			NAME_DEBUG=\"$(NAME_DEBUG_VAL)\" \
			LIBS_LINKS=\"$(LIBS_LINKS_DOCKER)\" \
			ASAN_CHECK=\"not_supported\" && \
			echo -e '[$(LOG_TIME)]$(CYN)[$(PROJECT)]	[DOCK-INFO]	Checking for executable...$(RST)'; \
			if [ ! -f \"$(NAME_DEBUG_VAL)\" ]; then \
				echo -e '[$(LOG_TIME)]$(RED)[$(PROJECT)]	[DOCK-ERROR]	Debug executable not found. Something went wrong during compilation...$(RST)'; \
				exit 1; \
			fi; \
			echo -e '[$(LOG_TIME)]$(CYNB)[$(PROJECT)]	[DOCK-INFO]	Valgrind build successfully compiled in persistent docker container!$(RST)' && \
			echo -e '[$(LOG_TIME)]$(CYNB)[$(PROJECT)]	[DOCK-RUN]	Running Valgrind analysis in persistent docker container...$(RST)' && \
			echo -e '-----------------------------------------' && \
			valgrind $(VALGRIND_FLAGS) --log-file=\"/app/$(VALGRIND_REPORT)\" \
			\"/app/$(NAME_DEBUG_VAL)\" \"$(ARGS)\"; \
			echo -e '\n-----------------------------------------'; \
			mv -f \"$(NAME_DEBUG_VAL)\" \"./$(DEBUG_DIR)\" 2>/dev/null "
			$(MAKE) process-valgrind-report REPORT_PATH=$(VALGRIND_REPORT)
			@mv -f $(NAME_DEBUG_VAL) $(VALGRIND_REPORT) ./$(DEBUG_DIR) 2>/dev/null || true

re-valgrind:
	$(call log_msg,$(BLU),INFO,	Rebuilding valgrind version from scratch)
ifeq ($(IS_LINUX),Linux)
	$(RM) $(OBJS_DEBUG_DIR)
else
	$(RM) $(OBJS_DOCKER_DIR)
endif
	$(RM) $(NAME_DEBUG_VAL_PATH) $(REPORT_PATH)
	$(MAKE) fclean-deep
	$(MAKE) valgrind


# ===== Docker setup =====

valgrind-docker-setup:
	$(MAKE) validate_env NAME=$(NAME_DEBUG_VAL)
	$(call log_msg,$(BLU),VALGRIND,Preparing Docker Valgrind environment...)
	@mkdir -p $(sort $(dir $(OBJS_DOCKER)))
	@if ! command -v docker >/dev/null 2>&1; then \
		$(call log_msg,$(RED),ERROR,	Docker is not installed. Please install Docker Desktop first.); \
		exit 1; \
	fi
	@if ! docker info >/dev/null 2>&1; then \
		$(call log_msg,$(RED),ERROR,	Docker daemon is not running. Please start Docker Desktop.); \
		exit 1; \
	fi
	# Check if Docker image exists and build if needed
	@if ! docker image inspect $(VALGRIND_IMAGE_NAME) >/dev/null 2>&1; then \
		$(call log_msg,$(BLU),VALGRIND,Creating [$(VALGRIND_DOCKERFILE)] Dockerfile...); \
		echo "FROM ubuntu:22.04" > $(VALGRIND_DOCKERFILE); \
		echo "ENV DEBIAN_FRONTEND=noninteractive" >> $(VALGRIND_DOCKERFILE); \
		echo "RUN apt-get update && apt-get install -y build-essential gcc make valgrind git && apt-get clean && rm -rf /var/lib/apt/lists/*" >> $(VALGRIND_DOCKERFILE); \
		echo "WORKDIR /app" >> $(VALGRIND_DOCKERFILE); \
		$(call log_msg,$(BLU),VALGRIND,Building Docker image with Valgrind...); \
		docker build -q -t $(VALGRIND_IMAGE_NAME) -f $(VALGRIND_DOCKERFILE) . ; \
		$(call log_msg,$(GRN),SUCCESS,Docker image [$(VALGRIND_IMAGE_NAME)] successfully created); \
	else \
		$(call log_msg,$(BLU),VALGRIND,Using existing Docker image [$(VALGRIND_IMAGE_NAME)] for Valgrind...); \
	fi

valgrind-container-start:
	$(call log_msg,$(BLU),VALGRIND,Starting persistent Valgrind container...)
	@if ! docker ps -a --format '{{.Names}}' | grep -q $(VALGRIND_PERS_CONT); then \
		$(call log_msg,$(BLU),VALGRIND,Creating [$(VALGRIND_PERS_CONT)] container...); \
		docker run -d --name $(VALGRIND_PERS_CONT) \
			-v $(CURDIR):/app \
			-w /app \
			$(VALGRIND_IMAGE_NAME) \
			sleep infinity \
			| xargs -I {} printf "[$(LOG_TIME)]$(BLU)[$(PROJECT)]	[DOCK-INFO]	[$(VALGRIND_PERS_CONT)] ID: {}$(RST)\n"; \
	elif ! docker ps --format '{{.Names}}' | grep -q $(VALGRIND_PERS_CONT); then \
		$(call log_msg,$(BLU),VALGRIND,Starting existing [$(VALGRIND_PERS_CONT)] container...); \
		docker start $(VALGRIND_PERS_CONT); \
	else \
		$(call log_msg,$(BLU),VALGRIND,Container [$(VALGRIND_PERS_CONT)] already running); \
	fi

valgrind-container-stop:
	$(call log_msg,$(BLU),DOCK-INFO,Stopping [$(VALGRIND_PERS_CONT)] docker container...)
	@if docker ps --format '{{.Names}}' | grep -q $(VALGRIND_PERS_CONT); then \
		docker stop valgrind-persistent 1>/dev/null && \
		$(call log_msg,$(BLU),DOCK-INFO,Container [$(VALGRIND_PERS_CONT)] successfully stopped!); \
	fi
	@if docker ps -a --format '{{.Names}}' | grep -q $(VALGRIND_PERS_CONT); then \
		docker rm $(VALGRIND_PERS_CONT) 1>/dev/null && \
		$(call log_msg,$(BLU),DOCK-INFO,Container [$(VALGRIND_PERS_CONT)] successfully removed!); \
	fi

build-docker_libs:
	@if [ -z "$(LIBS_CLEAN)" ]; then \
		$(call log_msg,$(YLW),DOCK-INFO,No libraries to build.); \
	else \
		$(call log_msg,$(BLUB),DOCK-INFO,Building docker libraries without relinking...); \
		for lib_dir in $(LIBS_DIRS); do \
			NAME=$$(basename "$$lib_dir").a; \
			$(MAKE) -C "$$lib_dir" 1>/dev/null 2>/dev/null; \
			LIB_FILE="$$lib_dir/$$NAME"; \
			if [ -f "$$LIB_FILE" ]; then \
				cp -f "$$LIB_FILE" "$(DOCKER_DIR)$$NAME_docker.a"; \
			else \
				$(call log_msg,$(RED),DOCK-ERROR,Library $$NAME was not generated in $$lib_dir!); \
				exit 1; \
			fi; \
		done; \
		$(call log_msg,$(GRN),DOCK-SUCCESS,All docker_libraries built and copied to $(DOCKER_DIR)); \
	fi


# ===== Valgrind processor =====

# Memory allocation and access errors
VALGRIND_MEM_ACCESS	= "Invalid read" "Invalid write" "Jump to the invalid address" \
					  "Address .* is .* bytes after a block of size" "Address .* is .* bytes before a block of size" \
					  ".* bytes in .* blocks are definitely lost"

# Memory management errors
VALGRIND_MEM_MGMT	= "Invalid free" "Mismatched free" "Invalid memory pool address"

# Uninitialized value errors
VALGRIND_UNINIT		= "Uninitialised value" "Use of uninitialised value" \
					  "Conditional jump or move depends on uninitialised value"

# Other errors
VALGRIND_OTHER		= "Source and destination overlap" "Syscall param" \
					  "Process terminating with non-zero status"

VALGRIND_ERRORS = $(VALGRIND_MEM_ACCESS) $(VALGRIND_MEM_MGMT) $(VALGRIND_UNINIT) $(VALGRIND_OTHER)

process-valgrind-report: #REPORT_PATH=$() full path needed es. ./valgrind_report.txt , standard one is debug/valgrind_report.txt
	@if [ ! -f "$(REPORT_PATH)" ]; then \
		$(call log_msg,$(RED),VAL-ERROR,Valgrind report not found at $(REPORT_PATH).); \
		exit 1; \
	fi; \
	$(call log_msg,$(BLU),VAL-INFO,Processing memory analysis results...); \
	if grep -q "ERROR SUMMARY: [1-9]" "$(REPORT_PATH)"; then \
		error_count=$$(grep "ERROR SUMMARY" "$(REPORT_PATH)" | awk '{print $$4}'); \
		$(call log_msg,$(REDB),VAL-ERROR,$$error_count memory errors detected); \
		\
		for error in $(VALGRIND_ERRORS); do \
			if grep -q "$$error" "$(REPORT_PATH)"; then \
				display_error=$$(echo "$$error" | sed 's/"//g'); \
				$(call log_msg,$(RED),VAL-ERROR,$$display_error detected:); \
				\
				error_line=$$(grep -n "$$error" "$(REPORT_PATH)" | head -1 | cut -d: -f1); \
				awk -v line=$$error_line -v err="$$error" ' \
					BEGIN { found=0; printed=0; } \
					NR >= line { \
						if ($$0 ~ err && found == 0) { \
							found=1; \
							print; \
							printed++; \
						} else if (found == 1) { \
							if ($$0 ~ /^==.*== $$/) { \
								exit; \
							} \
							print; \
							printed++; \
							if (printed >= 20) exit; \
						} \
					}' "$(REPORT_PATH)"; \
				\
				count=$$(grep -c "$$error" "$(REPORT_PATH)"); \
				if [ "$$count" -gt 1 ]; then \
					$(call log_msg,$(YLW),INFO,... ($$count total occurrences of this error type) ...); \
				fi; \
			fi; \
		done; \
	else \
		$(call log_msg,$(GRNB),VAL-SUCCESS,No memory errors detected.); \
	fi; \
	if grep -q "LEAK SUMMARY:" "$(REPORT_PATH)"; then \
		$(call log_msg,$(REDB),VAL-ERROR,Memory leaks detected:); \
		$(call log_msg,$(BLU),VAL-INFO,Memory leak summary:); \
		grep -A 5 "LEAK SUMMARY" "$(REPORT_PATH)"; \
	else \
		$(call log_msg,$(GRNB),VAL-SUCCESS,No memory leaks detected.); \
	fi; \
	$(call log_msg,$(YLWB),WARNING,Always double-check $(VALGRIND_REPORT) available in: $(DEBUG_DIR)$(VALGRIND_REPORT));


# ===== Git helpers =====

pull:
	$(call log_msg,$(BLU),GIT-INFO,Stashing any local changes...)
	@git stash push -m "Auto-stashed before pull by Makefile"
	$(call log_msg,$(BLU),GIT-INFO,Pulling latest changes...)
	@git pull
	$(call log_msg,$(BLU),GIT-INFO,Restoring stashed changes...)
	@git stash pop 2>/dev/null || $(call log_msg,$(BLU),GIT-INFO,No stashed changes to restore.)
	$(call log_msg,$(GRN),GIT-SUCCESS,Branch is now up-to-date.)

pull-all:
	$(call log_msg,$(BLU),GIT-INFO,Fetching all remote branches...)
	@git fetch --all
	$(call log_msg,$(BLU),GIT-INFO,Stashing any local changes...)
	@git stash push -m "Auto-stashed before update-all by Makefile" || true
	$(call log_msg,$(BLU),GIT-INFO,Updating all tracking branches...)
	@git pull --all
	$(call log_msg,$(BLU),GIT-INFO,Restoring stashed changes (if any)...)
	@git stash pop 2>/dev/null || $(call log_msg,$(BLU),GIT-INFO,No stashed changes to restore.)
	$(call log_msg,$(GRN),GIT-SUCCESS,All branches are now up-to-date.)

checkout:
	@if [ -z "$(to)" ]; then \
		$(call log_msg,$(RED),GIT-ERROR,Please provide a target branch with 'to=branch-name'); \
		exit 1; \
	fi
	@if [ -n "$$(git status --porcelain)" ]; then \
		$(call log_msg,$(YLW),GIT-WARNING,You have uncommitted changes. Stash them before checkout?); \
		$(call log_msg,$(YLW),GIT-WARNING,Type 'y' to stash changes or 'n' to proceed without stashing); \
		read -p "" CONFIRM && \
		if [ "$$CONFIRM" = "n" ]; then \
			$(call log_msg,$(YLW),GIT-WARNING,Proceeding with checkout without stashing. Changes may be lost or cause conflicts.); \
			$(call log_msg,$(BLU),GIT-INFO,Switching to branch: $(to)); \
			git checkout $(to) && $(call log_msg,$(GRN),GIT-SUCCESS,Successfully switched to $(to).) || \
				$(call log_msg,$(RED),GIT-ERROR,Failed to switch to $(to). Branch may not exist or you have conflicting changes.); \
		elif [ "$$CONFIRM" = "y" ]; then \
			$(call log_msg,$(BLU),GIT-INFO,Stashing local changes...); \
			git stash push -m "Auto-stashed before switching to $(to) by Makefile"; \
			$(call log_msg,$(BLU),GIT-INFO,Switching to branch: $(to)); \
			git checkout $(to) && $(call log_msg,$(GRN),GIT-SUCCESS,Successfully switched to $(to).) || \
				$(call log_msg,$(RED),GIT-ERROR,Failed to switch to $(to). Branch may not exist.); \
			$(call log_msg,$(BLU),GIT-INFO,Restoring stashed changes...); \
			git stash pop 2>/dev/null || $(call log_msg,$(BLU),GIT-INFO,No stashed changes to restore.); \
		else \
			$(call log_msg,$(RED),GIT-ERROR,Invalid input. Please type exactly 'y' or 'n'. Operation cancelled.); \
			exit 1; \
		fi; \
	else \
		$(call log_msg,$(BLU),GIT-INFO,No local changes detected. Switching to branch: $(to)); \
		git checkout $(to) && $(call log_msg,$(GRN),GIT-SUCCESS,Successfully switched to $(to).) || \
			$(call log_msg,$(RED),GIT-ERROR,Failed to switch to $(to). Branch may not exist.); \
	fi

commit:
	@if [ -z "$(m)" ]; then \
		$(call log_msg,$(RED),GIT-ERROR,Please provide a commit message with 'm=Your message'); \
		exit 1; \
	fi
	$(call log_msg,$(BLU),GIT-INFO,Adding all changes...)
	@git add .
	$(call log_msg,$(BLU),GIT-INFO,Committing with message: $(m))
	@git commit -m "$(m)"
	$(call log_msg,$(BLU),GIT-INFO,Pushing to remote...)
	@git push
	$(call log_msg,$(GRN),GIT-SUCCESS,Changes committed and pushed successfully.)

merge:
	@if [ -z "$(from)" ]; then \
		$(call log_msg,$(RED),GIT-ERROR,Please provide a source branch with 'from=branch-name'); \
		exit 1; \
	fi
	@if [ -n "$$(git status --porcelain)" ]; then \
		$(call log_msg,$(YLW),GIT-WARNING,You have uncommitted changes. Stash them before merging?); \
		$(call log_msg,$(YLW),GIT-WARNING,Type 'y' to stash changes or 'n' to proceed without stashing); \
		read -p "" CONFIRM && \
		if [ "$$CONFIRM" = "y" ]; then \
			$(call log_msg,$(BLU),GIT-INFO,Stashing local changes...); \
			git stash push -m "Auto-stashed before merging $(from) by Makefile"; \
			$(call log_msg,$(BLU),GIT-INFO,Merging $(from) into current branch...); \
			git merge $(from) && $(call log_msg,$(GRN),GIT-SUCCESS,Merge completed successfully.) || \
				$(call log_msg,$(RED),GIT-ERROR,Merge failed. Please resolve conflicts manually.); \
			$(call log_msg,$(BLU),GIT-INFO,Restoring stashed changes...); \
			git stash pop 2>/dev/null || $(call log_msg,$(BLU),GIT-INFO,No stashed changes to restore.); \
		elif [ "$$CONFIRM" = "n" ]; then \
			$(call log_msg,$(YLW),GIT-WARNING,Proceeding with merge WITHOUT stashing as requested. Your changes may cause conflicts.); \
			$(call log_msg,$(BLU),GIT-INFO,Merging $(from) into current branch...); \
			git merge $(from) && $(call log_msg,$(GRN),GIT-SUCCESS,Merge completed successfully.) || \
				$(call log_msg,$(RED),GIT-ERROR,Merge failed. Please resolve conflicts manually.); \
		else \
			$(call log_msg,$(RED),GIT-ERROR,Invalid input. Please type exactly 'y' or 'n'. Operation cancelled.); \
			exit 1; \
		fi; \
	else \
		$(call log_msg,$(BLU),GIT-INFO,No local changes detected. Proceeding with merge...); \
		$(call log_msg,$(BLU),GIT-INFO,Merging $(from) into current branch...); \
		git merge $(from) && $(call log_msg,$(GRN),GIT-SUCCESS,Merge completed successfully.) || \
			$(call log_msg,$(RED),GIT-ERROR,Merge failed. Please resolve conflicts manually.); \
	fi

is-clean:
	$(call log_msg,$(BLU),GIT-INFO,Checking working directory state...)
	@if [ -n "$$(git status --porcelain)" ]; then \
		$(call log_msg,$(YLW),GIT-WARNING,Working directory is not clean.); \
		git status -s; \
		exit 1; \
	else \
		$(call log_msg,$(GRN),GIT-SUCCESS,Working directory is clean.); \
	fi

clean-all:
	$(call log_msg,$(YLW),GIT-WARNING,This will discard all local changes. Are you sure?)
	$(call log_msg,$(YLW),GIT-WARNING,Type 'y' to confirm or 'n' to cancel)
	@read -p "" CONFIRM && \
	if [ "$$CONFIRM" = "y" ]; then \
		git reset --hard HEAD; \
		git clean -fd; \
		$(call log_msg,$(GRN),GIT-SUCCESS,All local changes have been discarded.); \
	elif [ "$$CONFIRM" = "n" ]; then \
		$(call log_msg,$(BLU),GIT-INFO,Operation cancelled.); \
	else \
		$(call log_msg,$(RED),GIT-ERROR,Invalid input. Please type exactly 'y' or 'n'. Operation cancelled.); \
		exit 1; \
	fi

reset-to-remote:
	@BRANCH=$$(git symbolic-ref --short HEAD) && \
	$(call log_msg,$(YLW),GIT-WARNING,This will reset the current branch ($$BRANCH) to match the remote.) && \
	$(call log_msg,$(YLW),GIT-WARNING,Type 'y' to confirm or 'n' to cancel) && \
	read -p "" CONFIRM && \
	if [ "$$CONFIRM" = "y" ]; then \
		$(call log_msg,$(BLU),GIT-INFO,Fetching latest remote state...); \
		git fetch origin && \
		$(call log_msg,$(BLU),GIT-INFO,Resetting branch to origin/$$BRANCH...); \
		git reset --hard origin/$$BRANCH && \
		$(call log_msg,$(GRN),GIT-SUCCESS,Branch has been reset to match remote.); \
	elif [ "$$CONFIRM" = "n" ]; then \
		$(call log_msg,$(BLU),GIT-INFO,Operation cancelled.); \
	else \
		$(call log_msg,$(RED),GIT-ERROR,Invalid input. Please type exactly 'y' or 'n'. Operation cancelled.); \
		exit 1; \
	fi


# ===== Help command =====

# Section headers
define print_section_header
	printf "\n$(BLU)%s:$(RST)\n" "$(1)"
endef

# Section separator
define print_separator
	printf "\n\n$(BLUB)+- %s -+$(RST)\n" "$(1)"
endef

# Command help entries
define print_cmd_help
	printf "  $(1)%-40s$(RST)-  $(WHT)%s$(RST)\n" "$(2)" "$(3)"
endef

# Configuration entries
define print_config_entry
	printf "  %-20s$(YLW)%s$(RST)\n" "$(1):" "$(2)"
endef

# Information entries
define print_info_entry
	printf "  %-20s%b\n" "$(1):" "$(2)"
endef


help:
	@echo ""
	$(call print_section_header,Configuration)
	$(call print_config_entry,Compiler,$(CC))
	$(call print_config_entry,Flags,$(CFLAGS))
	$(call print_config_entry,Debug Flags,$(DEBUG_FLAGS))
	$(call print_config_entry,Valgrind Flags,$(VALGRIND_FLAGS))
	$(call print_info_entry,Address Sanitizer,$(ASAN_CHECK)\n)

	$(call print_section_header,Compile & debug info)
	$(call print_info_entry,[$(words $(SRCS))] Source files,\n$(addsuffix \n, $(SRCS)))
	$(call print_info_entry,[$(words $(OBJS))] Object files,\n$(addsuffix \n, $(OBJS)))
	$(call print_info_entry,[$(words $(OBJS_BONUS))] Bonus Object files,\n$(addsuffix \n, $(OBJS_BONUS)))
	$(call print_info_entry,Private libraries,$(LIBS_PRIVATE))
	$(call print_info_entry,Submodule libraries,$(LIBS_SUBMODULE))
	$(call print_info_entry,External libraries,$(LIBS_EXTERNAL))


	$(call print_separator,Available Commands)

	$(call print_section_header,Main Commands)
	$(call print_cmd_help,$(GRN),make all,Build the project (default))
	$(call print_cmd_help,$(GRN),make validate_env,Checks if directory environment is set up)
	$(call print_cmd_help,$(GRN),make update_submodules,Initialize and update all submodules)
	$(call print_cmd_help,$(GRN),make clone_repos,Clone necessary repositories for local libraries)
	$(call print_cmd_help,$(GRN),make build-libs,Build all dependent libraries)
	$(call print_cmd_help,$(GRN),make re-build-libs,Rebuild all dependent libraries)
	$(call print_cmd_help,$(GRN),make re,Rebuild current project from scratch)
	$(call print_cmd_help,$(RED),make clean,Remove object files)
	$(call print_cmd_help,$(RED),make fclean,Remove all generated files)
	$(call print_cmd_help,$(GRN),make re-deep,Rebuild all libraries and project from scratch)
	$(call print_cmd_help,$(RED),make clean-deep,Clean all libraries and project objects)
	$(call print_cmd_help,$(RED),make fclean-deep,Full clean of all libraries and project)

	$(call print_section_header,Debug Commands)
	$(call print_cmd_help,$(CYN),make debug,Build with sanitizers for leak and error detection)
	$(call print_cmd_help,$(CYN),make debug-run,Run the program with sanitizers)
	$(call print_cmd_help,$(CYN),make leak-check,Memory leak detection with AddressSanitizer)
	$(call print_cmd_help,$(CYN),make debug-gdb,Build and debug with GDB)
	$(call print_cmd_help,$(GRN),make re-debug,Rebuild current debug version from scratch)
	$(call print_cmd_help,$(RED),make clean-debug,Remove debug objects)
	$(call print_cmd_help,$(RED),make fclean-debug,Remove all generated debug files)
	$(call print_cmd_help,$(CYN),make debug-makeflags,Display make flags information)

	$(call print_section_header,Valgrind Commands)
	$(call print_cmd_help,$(CYN),make valgrind,Auto-selects best Valgrind method for your platform (default))
	$(call print_cmd_help,$(CYN),make valgrind-native,Run Valgrind natively (Linux only))
	$(call print_cmd_help,$(CYN),make valgrind-docker,Run Valgrind via Docker (any platform))
	$(call print_cmd_help,$(CYN),make valgrind-docker_sleep,Run Valgrind in persistent Docker container)
	$(call print_cmd_help,$(CYN),make valgrind-container-start,Start persistent Valgrind container)
	$(call print_cmd_help,$(CYN),make valgrind-container-stop,Stop and remove persistent Valgrind container)
	$(call print_cmd_help,$(CYN),make process-valgrind-report,Process and display Valgrind report)
	$(call print_cmd_help,$(GRN),make re-valgrind,Rebuild and run Valgrind from scratch)
	$(call print_cmd_help,$(CYN),make build-libs_docker,Build libraries from Docker environment (Linux))

	$(call print_section_header,Git Integration Commands)
	$(call print_cmd_help,$(YLW),make pull,Pull latest changes safely (auto-stashes and restores))
	$(call print_cmd_help,$(YLW),make pull-all,Update all tracking branches from remote)
	$(call print_cmd_help,$(YLW),make checkout to=branch-name,Safely checkout a branch with auto-stashing if selected)
	$(call print_cmd_help,$(YLW),make commit m=\"Your message\",Commit and push changes in one command)
	$(call print_cmd_help,$(YLW),make merge from=source-branch,Safely merge branches with auto-stashing)
	$(call print_cmd_help,$(YLW),make is-clean,Check if working directory has uncommitted changes)
	$(call print_cmd_help,$(RED),make clean-all,Discard all local changes (with confirmation))
	$(call print_cmd_help,$(RED),make reset-to-remote,Discard all local and unpushed commits to match the remote (with confirmation))

	$(call print_section_header,Options)
	$(call print_cmd_help,$(MAG),VERBOSE=1,For detailed output)
	$(call print_cmd_help,$(MAG),DETAILS=1,For detailed files compilation)
	$(call print_cmd_help,$(MAG),BONUS=1,For Bonus debug compilation)
	$(call print_cmd_help,$(MAG),DEBUG=1,For debug mode -> Use #ifdef DEBUG ... #endif for debugging inside src)
	$(call print_cmd_help,$(MAG),SLEEP=1,For Docker valgrind in persistent container. Remember to run make valgrind-container-stop when needed)
	$(call print_cmd_help,$(MAG),ARGS=\"...\",To pass arguments to run tests (e.g make valgrind) if you need to. For multiple arguments use: ARGS='\"...\" \"...\"')

	$(call print_separator,------------------)
	@echo ""
	@echo "$(BLU)Makefile Ultimate by SabaDevvy$(RST)"
	@echo "$(BLU)https://github.com/SabaDevvy/makefile-ultimate$(RST)"
	@echo ""

.PHONY: all clean fclean re validate_env update_submodules clone_repos build-libs re-build-libs \
	clean-deep fclean-deep re-deep \
	debug debug-build debug-build_no_asan debug-run leak-check debug-gdb clean-debug fclean-debug re-debug debug-makeflags \
	valgrind valgrind-native valgrind-docker valgrind-docker-setup valgrind-docker_sleep re-valgrind \
	valgrind-container-start valgrind-container-stop build-libs_docker process-valgrind-report \
	pull pull-all checkout commit merge is-clean clean-all reset-to-remote \
	help
