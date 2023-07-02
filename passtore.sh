#!/usr/bin/env bash
#
# Copyright 2023 Meik Michalke <meik.michalke@c3s.cc>
#
# passtore.sh is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# passtore.sh is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with passtore.sh.  If not, see <http://www.gnu.org/licenses/>.

[[ "$1" =~ ^(--version)$ ]] && { 
    echo "2023-07-02";
    exit 0
};

HAVE_PROFILE=false
HAVE_STORE_NAME=false
NEED_STORE_NAME=false
IMPORTKEYS=false
IMPORTKEYS_WKD=false
FETCHKEY=false
FILTERCONF=false
LIST_KEYS=false
LIST_PERSONS=false
LIST_EMAIL=false
LIST_GROUPS=false
LIST_STORES=false
LIST_PW_FROM_RW_STORE=false
SHORT_LIST=false
STORE_NAMES_ONLY=false
FILTER_LIST=false
UPDATE_RO_STORE=false
UPDATE_RW_STORE=false
MOVE_PASSWORD=false
SYNC_PASSWORD=false
GENERATE_PASSWORD_RO=false
GENERATE_PASSWORD_RW=false
PASS_GEN_OPTIONS="--clip"
MANUAL_PW_LENGTH=false
MANUAL_PW_CHARS=false
MANUAL_GPGHOME=false
MANUAL_ASCROOT=false
INTEGRITYCHECKS_RO=false
INTEGRITYCHECKS_RW=false
EDIT_YAML=false
SIGN_YAML=false

XTRA_SPACE=""

USERNAME=$(whoami)
USERHOME="${HOME}"
BSSHAREDIR="${USERHOME}/.config/bash_scripts_${USERNAME}/shared"
# DATE="$(date +%Y-%m-%d_%H-%M-%S)"

# OLDWD="$(pwd)"
# trap "cd ${OLDWD}" EXIT

### BEGIN DEPENDENCY SECTION ###
# use some basic functions from the shared directory
# for usage information, you can run the scripts in bash to define
# the enclosed functions locally, and then the function names after
# "func_" with "-h", "--help", "--version", or no parameter, e.g.
#   warning --help
# minimum version requirements were initially defined during script creation
# run this to manually check for updates of base shared functions:
#   bash_script_skeleton.sh -I -s "${BSSHAREDIR}"
declare -A DEPENENDCIES=(
    # text formatting functions defined in colors_basic.sh:
    # _bifulnc
    # _biulnc (deprecated)
    # 
    # _dgray (+bifulnc)
    # _lgray (+bifulnc)
    # _lred (+bifulnc)
    # _red (+bifulnc)
    # _lblue (+bifulnc)
    # _blue (+bifulnc)
    # _green (+bifulnc)
    # _lpurple (+bifulnc)
    # _purple (+bifulnc)
    # _black (+bifulnc)
    # _brown (+bifulnc)
    # _yellow (+bifulnc)
    # _orange (+bifulnc)
    # _cyan (+bifulnc)
    # _lcyan (+bifulnc)
    # _white (+bifulnc)
    # _green_on_grey (+bifulnc)
    # _orange_on_grey (+bifulnc)
    # _bg_red (+bifulnc)
    # _bg_green (+bifulnc)
    # 
    # _bold
    # _italic
    # _faint
    # _underscore
    # _blink
    # _inverse
    # _concealed (invisible)
    # 
    # _opt (+ifulnc; for option parameter names)
    # _arg (+bfulnc; for option arguments)
    # _path (+bifulnc; for path names)
    # _info (+bifulnc; for general info, e.g., configuration files)
    # _linfo (+bifulnc; for further infos to options, e.g., defaults)
    ["${BSSHAREDIR}/colors_basic.sh"]="colors_basic >= 13"
    ["${BSSHAREDIR}/func_warning.sh"]="warning >= 3"
    ["${BSSHAREDIR}/func_skip.sh"]="skip >= 3"
    ["${BSSHAREDIR}/func_error.sh"]="error >= 3"
    ["${BSSHAREDIR}/func_alldone.sh"]="alldone >= 4"
    ["${BSSHAREDIR}/func_edit_file.sh"]="edit_file >= 1"
    ["${BSSHAREDIR}/func_min_version.sh"]="min_version >= 1"
    ["${BSSHAREDIR}/func_mkmissingdir.sh"]="mkmissingdir >= 7"
    ["${BSSHAREDIR}/func_path_exists.sh"]="path_exists >= 5"
    ["${BSSHAREDIR}/func_usage.sh"]="usage >= 7"
    # appends given text as a new line to given file
    #   usage: appendconfig [path] [grep] [body] (extra)
    #    [path]:  file name, full path
    #    [grep]:  stuff to grep for in [path] to check whether the entry is already there
    #    [body]:  full line to append to [path] otherwise
    #    (extra): the key word "sudo" if sudo is needed for the operation, "config" to silence skips
    ["${BSSHAREDIR}/func_appendconfig.sh"]="appendconfig >= 8"
    ["${BSSHAREDIR}/func_check_tool.sh"]="check_tool >= 3"
    # ["${BSSHAREDIR}/func_check_shared_script.sh"]="check_shared_script >= 10"
    # ["${BSSHAREDIR}/func_dependency_section.sh"]="dependency_section >= 1"
    # ["${BSSHAREDIR}/func_function_body.sh"]="function_body >= 2"
    # ["${BSSHAREDIR}/func_link_script.sh"]="link_script >= 5"
    # ["${BSSHAREDIR}/func_write_new_file.sh"]="write_new_file >= 2"
    ["${BSSHAREDIR}/func_yesno.sh"]="yesno >= 1"
)
# use check_shared_script to add your own shared functions;
# keep in mind they need to support both ^(-h|--help)$ and ^(-v|--version)$ parameters!
[[ "$1" =~ ^(--dependencies)$ ]] && {
    for i in ${!DEPENENDCIES[@]} ; do
      echo "${i} (${DEPENENDCIES[${i}]%% >=*} >= ${DEPENENDCIES[${i}]##*>= })"
    done
    exit 0
}
# now source the files needed in this script
for i in ${!DEPENENDCIES[@]} ; do
  [[ -f "${i}" ]] \
    || bash_script_skeleton.sh -I -s "${BSSHAREDIR}" || exit 1
  . "${i}" || exit 1
  [[ $(${DEPENENDCIES[${i}]%% >=*} --version) -ge $(echo ${DEPENENDCIES[${i}]##*>= }) ]] \
    || bash_script_skeleton.sh -I -s "${BSSHAREDIR}" || exit 1
done
unset i
# check for minimum version requirements
# min_version "bash_script_skeleton.sh" "--version" "2023-04-04"
### END DEPENDENCY SECTION ###

check_tool "gpg" "$(which gpg)"
check_tool "pass" "$(which pass)"
check_tool "yq" "$(which yq)"

### BEGIN CONFIG SECTION ###
# (uncomment & configure to use; include func_appendconfig.sh in the dependencies!)
CONFIGDIR="${USERHOME}/.config/bash_scripts_${USERNAME}"
CONFIGFILE="${CONFIGDIR}/passtore.conf"
if ! [ -f "${CONFIGFILE}" ] ; then
   mkmissingdir "${CONFIGDIR}"
   touch "${CONFIGFILE}"
fi
appendconfig "${CONFIGFILE}" "USERNAME" "\"${USERNAME}\"" "autoconfig"
appendconfig "${CONFIGFILE}" "USERHOME" "\"/home/\${USERNAME}\"" "autoconfig"
appendconfig "${CONFIGFILE}" "declare -A PRF_ASCROOT" "(\n  [\"example\"]=\"\${USERHOME}/mycloud/example/OpenPGP\"\n)\n" "autoconfig" \
    "you can provide multiple profiles like [\"example\"] by adding them to *all* arrays\n# PRF_ASCROOT defines a directory with *.asc OpenPGP keys"
appendconfig "${CONFIGFILE}" "declare -A PRF_STORE_RO" "(\n  [\"example\"]=\"\${USERHOME}/mycloud/example/admin/pass_store\"\n)\n" "autoconfig" \
    "PRF_STORE_RO is the actual main password store, if possible read-only for users"
appendconfig "${CONFIGFILE}" "declare -A PRF_STORE_RW" "(\n  [\"example\"]=\"\${USERHOME}/mycloud/example/admin/pass_incoming\"\n)\n" "autoconfig" \
    "PRF_STORE_RW is like a turnstile, users have write access and can\n# put new password files here for passadmins to examine and move to PRF_STORE_RO"
appendconfig "${CONFIGFILE}" "declare -A PRF_STORE_YAML" "(\n  [\"example\"]=\"\${PRF_STORE_RO[\"example\"]}/conf/passtore.yaml\"\n)\n" "autoconfig" \
    "PRF_STORE_YAML sets the path to the YAML configuration for this profile (defining users, keys, groups, stores)"
appendconfig "${CONFIGFILE}" "declare -A PRF_GPGHOME" "(\n  [\"example\"]=\"\${USERHOME}/.local/share/passtore/.gnupg\"\n)\n" "autoconfig" \
    "PRF_GPGHOME defines a directory for gpg to store public keys for encryption"
appendconfig "${CONFIGFILE}" "declare -A PRF_SIGN_KEYS" "(\n  [\"example\"]=\"1234567890ABCDEF1234567890ABCDEF12345678 ABCDEF1234567890ABCDEF1234567890ABCDEF12\"\n)\n" "autoconfig" \
    "PRF_SIGN_KEYS should match all valid signing keys defined in PRF_STORE_YAML as a local backup"
appendconfig "${CONFIGFILE}" "declare -A PRF_PERSONAL_SIGN_KEYS" "(\n  [\"example\"]=\"1234567890ABCDEF1234567890ABCDEF12345678\"\n)\n" "autoconfig" \
    "PRF_PERSONAL_SIGN_KEYS should contain the user's personal signing key(s)\n# the private key will be used from the user's GPGHOME, not PRF_GPGHOME!"
appendconfig "${CONFIGFILE}" "COL_WIDTH_PERSONS" "\"18\"" "autoconfig" "column width for person names, used only for pretty listing"
appendconfig "${CONFIGFILE}" "COL_WIDTH_EMAIL" "\"26\"" "autoconfig" "column width for email addresses, used only for pretty listing"

. "${CONFIGFILE}"

edit_file "${CONFIGFILE}" "--config" "$1" "unable to edit configuration file!"
### END CONFIG SECTION ###

edit_file "${0}" "--edit" "$1" "unable to edit script file!"

PROFILES=$(for i in ${!PRF_ASCROOT[@]} ; do
    echo -e "$(usage par "${i}")"
    echo -e "$(usage par_l "read-only location:  $(path_exists -d "${PRF_STORE_RO["${i}"]}" show)")"
    echo -e "$(usage par_l "writable location:   $(path_exists -d "${PRF_STORE_RW["${i}"]}" show)")"
    echo -e "$(usage par_l "store conf:          $(path_exists -f "${PRF_STORE_YAML["${i}"]}" show)")"
    echo -e "$(usage par_l "GnuPG home:          $(path_exists -d "${PRF_GPGHOME["${i}"]}" created)")"
    echo -e "$(usage par_l "public keys *.asc:   $(path_exists -d "${PRF_ASCROOT["${i}"]}" show)")"
done)

### BEGIN USAGE SECTION ###
if [[ "$1" =~ ^(-h|--help)$ || "$1" == "" ]] ; then
  echo -e "
  $(usage usage "${0##*/}" "[OPTIONS]")

  $(usage sect "OPTIONS")
    $(usage opt "-p" "<profile>" "select profile:")
                                $(usage note "note:" "if only one profile is defined, it will be used by default!")
                                ${PROFILES}

    $(usage opt "-L" "<type>"   "list from store configuration:")
                                $(usage par "k" "all defined OpenPGP keys")
                                $(usage par "p" "all persons with an OpenPGP key")
                                $(usage par "e" "all e-mail addresses with an OpenPGP key")
                                $(usage par "g" "all defined key groups")
                                $(usage par "s" "all defined stores")
                                $(usage par "S" "all defined stores (short variant)")
                                $(usage par "N" "all defined stores (store names only)")
                                $(usage note "examine the writable location:")
                                $(usage par "r" "all detected password directories in writable location")
    $(usage opt "-e" "<expr>"   "if given, $(_opt "-L") will be limited to results that match $(_arg "<expr>")")

    $(usage opt "-s" "<store>"  "set the store name to $(_arg "<store>")")
    $(usage opt "-i" ""         "initialize or update the read-only store directory configured by $(_opt "-s")")
                                $(usage info \
                                    "- create missing directories" \
                                    "- create/overwrite a .gpg-id file with the configured key IDs" \
                                    "- sign the .gpg-id file with personal signing key" \
                                )
    $(usage opt "-w" ""         "same as $(_opt "-i") but affecting the writable store")
    $(usage opt "-m" "<rpath>"  "move a password file from writable store to the one set by $(_opt "-s")")
                                $(usage note "note" "only use the relative path as shown by $(_opt "-L") $(_arg "r")!")
                                $(usage info \
                                    "- implies $(_opt "-i")" \
                                    "- only files with .gpg extension are supported"
                                )
    $(usage opt "-M" "<store>"  "same as $(_opt "-m") but expecting identical file structure in writable and read-only store")
    $(usage opt "-n" "<name>"   "generate a new password file named $(_arg "<name>") in the read-write store set by $(_opt "-s")")
                                $(usage info \
                                    "- implies $(_opt "-i")"
                                )
    $(usage opt "-N" "<name>"   "same as $(_opt "-n") but generates new files in writable store")
                                $(usage info \
                                    "- implies $(_opt "-w")"
                                )
    $(usage opt "-l" "<length>" "manually overwrite default length for new passwords generated with $(_opt "-n")")
                                $(usage default "$(_linfo "see" i) $(_opt "-L") $(_arg "s") $(_opt "-e") $(_arg "<store>")")
    $(usage opt "-c" "<chars>"  "manually overwrite default character set for new passwords generated with $(_opt "-n")")
                                $(usage default "$(_linfo "see" i) $(_opt "-L") $(_arg "s") $(_opt "-e") $(_arg "<store>")")
    $(usage opt "-t" ""         "show password generated via $(_opt "-n") in terminal")
                                $(usage default "$(_linfo "copy to clipboard for 45 seconds" i)")

    $(usage opt "-C" ""         "perform integrity checks (read-only store)")
                                $(usage info \
                                    "- are all directories in the read-only location defined in YAML store conf?" \
                                    "- do signing keys match (YAML == local config file)?" \
                                    "- do all .gpg-id files and YAML conf have a valid signature?" \
                                    "- are all keys in .gpg-id files (still) valid?" \
                                    "- does encryption exactly match keys in .gpg-id files?" \
                                )
    $(usage opt "-R" ""         "perform integrity checks (writable store)")
                                $(usage info \
                                    "- are all directories in the writable location defined in YAML store conf?" \
                                    "- are all keys in .gpg-id files valid?" \
                                    "- does encryption exactly match keys in .gpg-id files?" \
                                )

    $(usage opt "-I" ""         "import all *.asc files (public keys) from profile or $(_opt "-A") into keyring set by profile or $(_opt "-G")")
                                $(usage info "gpg --homedir \"<path>\" --quiet --import \"<key_n.asc>\"")
    $(usage opt "-W" ""         "fetch all keys in store configuration from WKD and import into keyring set by profile or $(_opt "-G")")
                                $(usage info "like ${OFF}$(_opt "-f") $(_linfo "but for all e-mail addresses in YAML configuration")")

    $(usage opt "-f" "<pattern>" "fetch key matching the pattern from WKD and import into keyring set by profile or $(_opt "-G")")
                                $(usage info "gpg --homedir \"<path>\" --auto-key-locate clear,wkd,nodefault --locate-external-keys \"<pattern>\"")

    $(usage opt "-G" "<path>"   "overwrite GnuPG home directory (location of the keyring to use)")
                                $(usage default "$(_linfo "see profile" i)")
    $(usage opt "-A" "<path>"   "overwrite root directory with exported public keys in *.asc files")
                                $(usage default "$(_linfo "see profile" i)")

    $(usage opt "-y" ""         "open the YAML configuration file of profile $(_opt "-p") in editor")
                                $(usage info "if no YAML configuration exists yet, an example will be created and opened")
    $(usage opt "-Y" ""         "sign the YAML configuration file of profile $(_opt "-p") with your signing key")

  $(usage conf "${CONFIGFILE}" "--version" "--dependencies" "--config" "--edit")
"
  exit 0
fi
### END USAGE SECTION ###

# get the options
while getopts ":p:L:e:s:iwm:M:n:N:l:c:tCRIWf:G:A:yY" OPT; do
    case $OPT in
        p) CONFPROFILE="${OPTARG}" >&2
           [[ " ${!PRF_ASCROOT[@]} " =~ " ${CONFPROFILE} " ]] || error "invalid profile: ${CONFPROFILE}"
           HAVE_PROFILE=true >&2
           ;;
        L) FILTERCONF=true >&2
           case $OPTARG in
               k) LIST_KEYS=true >&2
                  ;;
               p) LIST_PERSONS=true >&2
                  ;;
               e) LIST_EMAIL=true >&2
                  ;;
               g) LIST_GROUPS=true >&2
                  ;;
               s) LIST_STORES=true >&2
                  ;;
               S) LIST_STORES=true >&2
                  SHORT_LIST=true >&2
                  ;;
               N) LIST_STORES=true >&2
                  STORE_NAMES_ONLY=true >&2
                  ;;
               r) LIST_PW_FROM_RW_STORE=true >&2
                  ;;
               \?)
                  error "unknown filter type: $(_opt "${OPTARG}")" >&2
                  ;;
           esac
           ;;
        e) FILTER_LIST=true >&2
           FILTER_EXPR="${OPTARG}" >&2
           ;;
        s) STORE_NAME="${OPTARG}" >&2
           HAVE_STORE_NAME=true >&2
           ;;
        i) UPDATE_RO_STORE=true >&2
           NEED_STORE_NAME=true >&2
           ;;
        w) UPDATE_RW_STORE=true >&2
           NEED_STORE_NAME=true >&2
           ;;
        m) MOVE_PASSWORD=true >&2
           RW_PW_FILE="${OPTARG}" >&2
           NEED_STORE_NAME=true >&2
           ;;
        M) SYNC_PASSWORD=true >&2
           STORE_NAME="${OPTARG}" >&2
           HAVE_STORE_NAME=true >&2
           ;;
        n) GENERATE_PASSWORD_RO=true >&2
           NEW_PW_FILE="${OPTARG}" >&2
           NEED_STORE_NAME=true >&2
           ;;
        N) GENERATE_PASSWORD_RW=true >&2
           NEW_PW_FILE="${OPTARG}" >&2
           NEED_STORE_NAME=true >&2
           ;;
        l) PASSWORD_LENGTH="${OPTARG}" >&2
           MANUAL_PW_LENGTH=true >&2
           ;;
        c) PASSWORD_STORE_CHARACTER_SET="${OPTARG}" >&2
           MANUAL_PW_CHARS=true >&2
           ;;
        t) PASS_GEN_OPTIONS="" >&2
           ;;
        A) MANUAL_ASCROOT=true >&2
           ASCROOT="${OPTARG}" >&2
           ;;
        f) FETCHKEY=true >&2
           PATTERN="${OPTARG}" >&2
           ;;
        I) IMPORTKEYS=true >&2
           ;;
        W) IMPORTKEYS_WKD=true >&2
           ;;
        G) MANUAL_GPGHOME=true >&2
           GPGHOME="${OPTARG}" >&2
           ;;
        C) INTEGRITYCHECKS_RO=true >&2
           ;;
        R) INTEGRITYCHECKS_RW=true >&2
           ;;
        y) EDIT_YAML=true >&2
           ;;
        Y) SIGN_YAML=true >&2
           ;;
        \?)
           error "Invalid option: $(_opt "-${OPTARG}")" >&2
           ;;
        :)
           error "Option $(_opt "-${OPTARG}") requires an argument." >&2
           ;;
    esac
done

### BEGIN SCRIPT BODY ###
if ! ${HAVE_PROFILE} ; then
    # use profile if only a single one is defined
    if [[ "${#PRF_ASCROOT[@]}" -gt 1 ]] ; then
        error "you must select a profile via $(_opt "-p")!"
    else
        CONFPROFILE="${!PRF_ASCROOT[@]}"
        HAVE_PROFILE=true >&2
    fi
fi


${NEED_STORE_NAME} && ! ${HAVE_STORE_NAME} \
    && error "you must set a valid store name via $(_opt "-s")!"


STORE_RO="${PRF_STORE_RO["${CONFPROFILE}"]}"
STORE_RW="${PRF_STORE_RW["${CONFPROFILE}"]}"
STORE_YAML="${PRF_STORE_YAML["${CONFPROFILE}"]}"
! ${MANUAL_GPGHOME} && GPGHOME="${PRF_GPGHOME["${CONFPROFILE}"]}"
! ${MANUAL_ASCROOT} && ASCROOT="${PRF_ASCROOT["${CONFPROFILE}"]}"
SIGN_KEYS="${PRF_SIGN_KEYS["${CONFPROFILE}"]}"
PERSONAL_SIGN_KEYS="${PRF_PERSONAL_SIGN_KEYS["${CONFPROFILE}"]}"
# strip trailing slashes
STORE_RO="${STORE_RO%/}"
STORE_RW="${STORE_RW%/}"
GPGHOME="${GPGHOME%/}"
ASCROOT="${ASCROOT%/}"

${EDIT_YAML} && {
    if ! [[ -f "${STORE_YAML}" ]] ; then
        YAML_DIR="${STORE_YAML%/*}"
        # also strip a conf dir which should be there
        # the root dir of that must already exist
        YAML_DIR_ROOT="${YAML_DIR%/conf}"
        echo -e "\nno YAML configuration found, creating an example:"
        [[ -d "${YAML_DIR_ROOT}" ]] \
            && echo -e "  $(_info "- YAML directory:") $(path_exists -d "${YAML_DIR}" created)" \
            || error "the YAML root directory does not exist: $(path_exists -d "${YAML_DIR_ROOT}" show)"
        ! [[ -d "${YAML_DIR}" ]] && {
            echo -n "  - "
            mkmissingdir "${YAML_DIR}"
        }
        EXAMPLEYAMLCONTENT="---
keys:
  # each user must have
  # - a name
  # - an email address
  # - an OpenPGP key id
  users:
    - name:  First Person
      email: first.person@example.com
      keyid: ABCDEF1234567890ABCDEF1234567890ABCDEF12

    - name:  Second Pal
      email: second.pal@example.com
      keyid: 1234567890ABCDEF1234567890ABCDEF12345678

    - name:  Third Dude
      email: the.dude@example.com
      keyid: 90ABCDEF1234567890ABCDEF1234567890ABCDEF

  # each group must have
  # - a name
  # - a list of members
  # the group named 'passadmin' is mandatory!
  # it defines the valid key IDs for signing files (.yaml/.gpg-id)
  groups:
    - name: passadmin
      members:
        - First Person
        - Second Pal

    - name: readall
      members:
        - Second Pal

    - name: sysadmin
      members:
        - First Person
        - Third Dude

    - name: readonly
      members:
        - First Person
        - Second Pal
        - Third Dude

    - name: social media
      members:
        - Third Dude

# this is the global defaults
# can be overwritten per store
defaults:
    pass:
      length: 30
      characters: '[:alnum:].,!?&*%_~\$#^@{}[]()<>|=/\\\\+-'

# each store must have
# - a name to address the store
# - a path *relative* to \${PRF_STORE_RO} of the profile as set in the local config file
#   (each directory should be listed, assuming symmetry between \${PRF_STORE_RO} and
#   \${PRF_STORE_RW})
# - a groups entry called 'read' which defines the key IDs for its .gpg-id
#   (since all groups have members and each member has a key ID)
stores:
  - name: main
    # the \"main\" store with an empty path is mandatory!
    # it defines the .gpg-id in the store root directory
    path:
    groups:
      read:
        - readonly
        - readall
  - name: server admin
    path: server_admin
    groups:
      read:
        - sysadmin
        - readall
  - name: social media
    path: social_media
    groups:
      read:
        - social media
        - readall
  - name: mastodon
    path: social_media/mastodon
    groups:
      read:
        - social media
        - readall
  - name: test
    path: test/store
    groups:
      read:
        - readonly
        - readall
    # here's an example for different password defaults
    pass:
      length: 40
      characters: '[:alnum:].,!?&*%_~\$#^@{}[]()<>|=/\\\\+-'
..."
        echo "${EXAMPLEYAMLCONTENT}" > "${STORE_YAML}"
    fi
    ${VISUAL:-${EDITOR:-vi}} "${STORE_YAML}" || error "unable to edit YAML file!"
    exit 0
};

${SIGN_YAML} && {
    readarray -t -d " " PERSONAL_SIGNKEYS_IN_CONF < <(echo -n "${PERSONAL_SIGN_KEYS}")
    MYSIGNKEYS=""
    for i in "${PERSONAL_SIGNKEYS_IN_CONF[@]}" ; do
        MYSIGNKEYS+="--local-user ${i} "
    done
    gpg ${MYSIGNKEYS} --output "${STORE_YAML}.sig" --detach-sig "${STORE_YAML}" || error "unable to sign YAML file!"
    unset MYSIGNKEYS
    unset PERSONAL_SIGNKEYS_IN_CONF
    exit 0
};


yaml2array (){
    [[ "$1" =~ ^(-h|--help)$ || "$1" == "" ]] && {
        echo "generates an array from selections of a yaml file

    usage: yaml2array [array] [mode] [yaml] [var1] (var2) (var3)

        [array]:  name of the array to generate
        [mode]:   either \"file\" or \"var\"
        [yaml]:   depending on [mode], either path to YAML file or a variable
                  with YAML content
        [var1]:   one of the following, defining what part you want in the
                  array:
                  - \"keys\":      all valid OpenPGP key IDs
                  - \"persons\":   all persons with a valid OpenPGP key ID
                  - \"email\":     all e-mail addresses with a valid OpenPGP key ID
                  - \"groups\":    the names of all defined groups
                  - \"members\":   the names of all members of a named group
                  - \"stores\":    the names of all defined stores
                  - \"access\":    the names of all groups with named access privileges
        (var2):   if [var1] is \"members\", provide the name of a group,
                  if [var1] is \"access\", the name of a store
        (var3):   if [var1] is \"access\", must be one of:
                  - \"read\"
                  - \"path2read\"
                  - \"sign\"
        "
        return;
    }
    [[ "$1" =~ ^(-v|--version)$ ]] && {
        echo "2"
        return;
    }
    local ARRAY="$1"
    local MODE="$2"
    local YAML="$3"
    local VAR1="$4"
    local VAR2="$5"
    local VAR3="$6"
    local YP_VALUE=""
    if [[ "${MODE}" == "file" ]] ; then
        YAML=$(<${YAML})
    elif [[ "${MODE}" != "var" ]] ; then
        error "unknown mode: ${MODE}!"
    fi
    # NOTE: the '-t' option is necessary to strip newline characters from entries
    case $VAR1 in
        keys)
            readarray -t "${ARRAY}" < <(echo "${YAML}" | yq '.keys.users[].keyid' | sort)
            ;;
        persons)
            readarray -t "${ARRAY}" < <(echo "${YAML}" | yq '.keys.users[].name' | sort)
            ;;
        email)
            readarray -t "${ARRAY}" < <(echo "${YAML}" | yq '.keys.users[].email' | sort)
            ;;
        groups)
            readarray -t "${ARRAY}" < <(echo "${YAML}" | yq '.keys.groups[].name' | sort)
            ;;
        members)
            readarray -t "${ARRAY}" < <(echo "${YAML}" | YP_VALUE="${VAR2}" yq '.keys.groups[] | select(.name == env(YP_VALUE)).members[]' | sort)
            ;;
        stores)
            readarray -t "${ARRAY}" < <(echo "${YAML}" | yq '.stores[].name' | sort)
            ;;
        access)
            case $VAR3 in
                read)
                    readarray -t "${ARRAY}" < <(echo "${YAML}" | YP_VALUE="${VAR2}" yq '.stores[] | select(.name == env(YP_VALUE)).groups.read[]' | sort)
                    ;;
                path2read)
                    # edge case: the root directory can't be matched by its relative path because that's an
                    # empty string. instead, look for the "main" store
                    if [[ "${VAR2}" == "" ]] ; then
                        readarray -t "${ARRAY}" < <(echo "${YAML}" | YP_VALUE="main" yq '.stores[] | select(.name == env(YP_VALUE)).groups.read[]' | sort)
                    else
                        readarray -t "${ARRAY}" < <(echo "${YAML}" | YP_VALUE="${VAR2}" yq '.stores[] | select(.path == env(YP_VALUE)).groups.read[]' | sort)
                    fi
                    ;;
                sign)
                    readarray -t "${ARRAY}" < <(echo "passadmin")
                    ;;
                \?)
                    error "invalid group type: $(_blue "${VAR3}")" >&2
                    ;;
            esac
            ;;
        *)
            error "invalid variable: $(_blue "${VAR1}")" >&2
            ;;
    esac
}

query_yaml () {
    [[ "$1" =~ ^(-h|--help)$ || "$1" == "" ]] && {
        echo "get value from a YAML configuration.

the node set by [sel_var] defines which other values can be queried.
e.g., if you select a key user by a key ID, you can query for the key user's
name or e-mail address.

    usage: query_yaml [mode] [yaml] [sel_var] [sel_value] [query]

        [mode]:      either \"file\" or \"var\"
        [yaml]:      depending on [mode], either path to YAML file or a
                     variable with YAML content
        [sel_var]:   one of the following, defining what part you want to
                     select by:
                     - \"key_user_name\"
                     - \"key_user_email\"
                     - \"key_user_keyid\"
                     - \"key_group_name\"
                     - \"store_name\"
                     - \"store_path\"
        [sel_value]  the value of [sel_var] to select by
        [query]      the value you are looking for. one of the following,
                     availability depending on [sel_var]:
                     - \"name\"
                     - \"email\"
                     - \"keyid\"
                     - \"members\"
                     - \"path\"
                     - \"groups_read\"
                     - \"pw_length\"
                     - \"pw_chars\"
        "
        return;
    }
    [[ "$1" =~ ^(-v|--version)$ ]] && {
        echo "1"
        return;
    }
    local MODE="$1"
    local YAML="$2"
    local SEL_VAR="$3"
    local SEL_VALUE="$4"
    local QUERY="$5"

    local YP_VALUE=""
    local WRONG=false
    local RESULT=""
    if [[ "${MODE}" == "file" ]] ; then
        YAML=$(<${YAML})
    elif [[ "${MODE}" != "var" ]] ; then
        error "unknown mode: ${MODE}!"
    fi
    case $SEL_VAR in
        key_user_name)
            case $QUERY in
                email)
                    RESULT=$(echo "${YAML}" | YP_VALUE="$SEL_VALUE" yq '.keys.users[] | select(.name == env(YP_VALUE)).email') >&2
                    ;;
                keyid)
                    RESULT=$(echo "${YAML}" | YP_VALUE="$SEL_VALUE" yq '.keys.users[] | select(.name == env(YP_VALUE)).keyid') >&2
                    ;;
                \?)
                    WRONG=true >&2
                    ;;
            esac
            ;;
        key_user_email)
            case $QUERY in
                name)
                    RESULT=$(echo "${YAML}" | YP_VALUE="$SEL_VALUE" yq '.keys.users[] | select(.email == env(YP_VALUE)).name') >&2
                    ;;
                keyid)
                    RESULT=$(echo "${YAML}" | YP_VALUE="$SEL_VALUE" yq '.keys.users[] | select(.email == env(YP_VALUE)).keyid') >&2
                    ;;
                \?)
                    WRONG=true >&2
                    ;;
            esac
            ;;
        key_user_keyid)
            case $QUERY in
                name)
                    RESULT=$(echo "${YAML}" | YP_VALUE="$SEL_VALUE" yq '.keys.users[] | select(.keyid == env(YP_VALUE)).name') >&2
                    ;;
                email)
                    RESULT=$(echo "${YAML}" | YP_VALUE="$SEL_VALUE" yq '.keys.users[] | select(.keyid == env(YP_VALUE)).email') >&2
                    ;;
                \?)
                    WRONG=true >&2
                    ;;
            esac
            ;;
        key_group_name)
            case $QUERY in
                members)
                    RESULT=$(echo "${YAML}" | YP_VALUE="$SEL_VALUE" yq '.keys.groups[] | select(.name == env(YP_VALUE)).members[]') >&2
                    ;;
                \?)
                    WRONG=true >&2
                    ;;
            esac
            ;;
        store_name)
            case $QUERY in
                path)
                    RESULT=$(echo "${YAML}" | YP_VALUE="$SEL_VALUE" yq '.stores[] | select(.name == env(YP_VALUE)).path') >&2
                    ;;
                pw_length)
                    RESULT=$(echo "${YAML}" | YP_VALUE="$SEL_VALUE" yq '.stores[] | select(.name == env(YP_VALUE)).pass.length') >&2
                    [[ "${RESULT}" == "null" ]] && RESULT=$(echo "${YAML}" | YP_VALUE="$SEL_VALUE" yq '.defaults.pass.length') >&2
                    ;;
                pw_chars)
                    RESULT=$(echo "${YAML}" | YP_VALUE="$SEL_VALUE" yq '.stores[] | select(.name == env(YP_VALUE)).pass.characters') >&2
                    [[ "${RESULT}" == "null" ]] && RESULT=$(echo "${YAML}" | YP_VALUE="$SEL_VALUE" yq '.defaults.pass.characters') >&2
                    ;;
                \?)
                    WRONG=true >&2
                    ;;
            esac
            ;;
        store_path)
            case $QUERY in
                name)
                    RESULT=$(echo "${YAML}" | YP_VALUE="$SEL_VALUE" yq '.stores[] | select(.path == env(YP_VALUE)).name') >&2
                    ;;
                groups_read)
                    RESULT=$(echo "${YAML}" | YP_VALUE="$SEL_VALUE" yq '.stores[] | select(.path == env(YP_VALUE)).groups.read[]') >&2
                    ;;
                pw_length)
                    RESULT=$(echo "${YAML}" | YP_VALUE="$SEL_VALUE" yq '.stores[] | select(.path == env(YP_VALUE)).pass.length') >&2
                    [[ "${RESULT}" == "null" ]] && RESULT=$(echo "${YAML}" | YP_VALUE="$SEL_VALUE" yq '.defaults.pass.length') >&2
                    ;;
                pw_chars)
                    RESULT=$(echo "${YAML}" | YP_VALUE="$SEL_VALUE" yq '.stores[] | select(.path == env(YP_VALUE)).pass.characters') >&2
                    [[ "${RESULT}" == "null" ]] && RESULT=$(echo "${YAML}" | YP_VALUE="$SEL_VALUE" yq '.defaults.pass.characters') >&2
                    ;;
                \?)
                    WRONG=true >&2
                    ;;
            esac
            ;;
        *)
            error "invalid selection: $(_blue "$SEL_VAR")" >&2
            ;;
    esac

    if ${WRONG} ; then
        error "invalid query for $(_blue "$SEL_VAR"): $(_blue "$SEL_VALUE")"
    fi
    echo "${RESULT}"
}

_keyid () {
    # prints a 40-character key ID with alternating octets
    local KEYID="$1"
    echo -e "$(_blue "${KEYID:0:8}")$(_blue "${KEYID:8:8}" f)$(_blue "${KEYID:16:8}")$(_blue "${KEYID:24:8}" f)$(_blue "${KEYID:32:8}" b)"
}

filter_array () {
    [[ "$1" =~ ^(-h|--help)$ || "$1" == "" ]] && {
        echo "filter array by expression

    usage: filter_array [doit] [array] [expr]

        [doit]:      logical, whether filtering should be applied
        [array]:     the array to filter
        [expr]:      the expression to look for. only matches will remain in the array
        "
        return;
    }
    [[ "$1" =~ ^(-v|--version)$ ]] && {
        echo "1"
        return;
    }
    local DOIT="$1";
    local -n ARRAY=$2;
    local EXPR="$3";
    local i;
    if $DOIT ; then
        for i in "${!ARRAY[@]}"; do
            if ! [[ ${ARRAY[$i]} =~ ${EXPR} ]]; then
                unset 'ARRAY[i]'
            fi
        done
    fi
}

dir_array () { 
    [[ "$1" =~ ^(-h|--help)$ || "$1" == "" ]] && { 
        echo "generates an array of subdirectory names of a given directory matching regexp

    usage: dir_array [array] [path] (find)

        [array]:  name of the array to generate
        [path]:   directory to search
        (find):   additional options for find (optional)
        ";
        return
    };
    [[ "$1" =~ ^(-v|--version)$ ]] && { 
        echo "1";
        return
    };
    local ARRAY="$1";
    local DIRPATH="$2";
    local FINDOPTS="$3";
    [[ "${FINDOPTS}" != "" ]] \
        && readarray -d '' "${ARRAY}" < <(find "${DIRPATH}" -type d ${FINDOPTS} -print0 | sort -z) \
        || readarray -d '' "${ARRAY}" < <(find "${DIRPATH}" -type d -print0 | sort -z)
}

groups2keys_array () {
    [[ "$1" =~ ^(-h|--help)$ || "$1" == "" ]] && { 
        echo "allows to provide an array of group names to get a uniqe array of key IDs

    returns an unnamed array (i.e., its content)

    usage: groups2keys_array [yaml] [groups]

        [yaml]:   the YAML content
        [groups]: array of group names
        ";
        return
    };
    [[ "$1" =~ ^(-v|--version)$ ]] && { 
        echo "1";
        return
    };

    local YAML_CONTENT="$1";
    declare -n GROUPARRAY=$2;
    local KEY_ARRAY=();
    local YAMLARRAY_GROUPMEMBERS;
    local i;
    local j;
    for i in "${GROUPARRAY[@]}" ; do
        yaml2array YAMLARRAY_GROUPMEMBERS var "${YAML_CONTENT}" "members" "${i}"
        for j in "${YAMLARRAY_GROUPMEMBERS[@]}" ; do
            readarray -t -O "${#KEY_ARRAY[@]}" "KEY_ARRAY" < <(for i in $(query_yaml var "${YAML_CONTENT}" "key_user_name" "${j}" "keyid"); do echo $i ; done)
        done
        unset YAMLARRAY_GROUPMEMBERS
    done
    KEY_ARRAY=($(printf "%s\n" "${KEY_ARRAY[@]}" | sort -u))
    echo ${KEY_ARRAY[@]}
}

list_yaml () {
    [[ "$1" =~ ^(-h|--help)$ || "$1" == "" ]] && { 
        echo "lists info from YAML content

    usage: list_yaml [yaml] [what] [indent] (regexp) (store) (regexp2) (root)

        [yaml]:   the YAML content
        [what]:   one of:
                    - \"k\": all defined OpenPGP keys
                    - \"p\": all persons with an OpenPGP key
                    - \"e\": all e-mail addresses with an OpenPGP key
                    - \"g\": all defined key groups
                    - \"s\": all defined stores
                    - \"S\": all defined stores (short)
                    - \"N\": all defined stores (names only)
                    - \"r\": all detected password directories in writable location
        [indent]:  spaces to indent results
        (regexp):  regular expression to filter results by (optional)
        (store):   mandatory for \"r\": the RW store to search
        (regexp2): optional for \"r\": regular expression to filter password files by
        (root):    optional for \"s\"/\"S\", alternative root directory if not read-only
        ";
        return
    };
    [[ "$1" =~ ^(-v|--version)$ ]] && { 
        echo "1";
        return
    };

    local YAML_CONTENT="$1"
    local LIST_KEYS=false
    local LIST_PERSONS=false
    local LIST_EMAIL=false
    local LIST_GROUPS=false
    local LIST_STORES=false
    local LIST_PW_FROM_RW_STORE=false
    local SHORT_LIST=false
    case $2 in
        k) LIST_KEYS=true >&2
            ;;
        p) LIST_PERSONS=true >&2
            ;;
        e) LIST_EMAIL=true >&2
            ;;
        g) LIST_GROUPS=true >&2
            ;;
        s) LIST_STORES=true >&2
            ;;
        S) LIST_STORES=true >&2
           SHORT_LIST=true >&2
            ;;
        N) LIST_STORES=true >&2
           STORE_NAMES_ONLY=true >&2
            ;;
        r) LIST_PW_FROM_RW_STORE=true >&2
            ;;
        *)
            error "unknown filter type: $(_opt "${OPTARG}")" >&2
            ;;
    esac
    local INDENT="$3";
    local FILTER_EXPR="$4";
    local FILTER_LIST=false;
    [[ "${FILTER_EXPR}" != "" ]] && FILTER_LIST=true
    local RW_STORE="$5";
    local FILTER_EXPR2="$6";
    local YAMLARRAY;
    local YAMLGROUPMEMBERS;
    local YAMLSTOREREAD;
    local YAMLSTORESIGN;
    local i;
    local j;
    local k;
    local STORE_ROOT_DIR="$7"
    [[ "${STORE_ROOT_DIR}" == "" ]] && STORE_ROOT_DIR="${STORE_RO}"
    if ${LIST_KEYS} ; then
        yaml2array YAMLARRAY var "${YAML_CONTENT}" "keys"
        filter_array "${FILTER_LIST}" YAMLARRAY "${FILTER_EXPR}"
        for i in ${!YAMLARRAY[@]} ; do
            echo -en "${INDENT}$(_lgray "\u25B8") $(_keyid "${YAMLARRAY[${i}]}")"
            echo -en "   $(printf "%-${COL_WIDTH_PERSONS}s" "$(query_yaml var "${YAML_CONTENT}" "key_user_keyid" "${YAMLARRAY[${i}]}" "name")")"
            echo -e " $(_dgray "<$(query_yaml var "${YAML_CONTENT}" "key_user_keyid" "${YAMLARRAY[${i}]}" "email")>")"
        done
    elif ${LIST_PERSONS} ; then
        yaml2array YAMLARRAY var "${YAML_CONTENT}" "persons"
        filter_array "${FILTER_LIST}" YAMLARRAY "${FILTER_EXPR}"
        for i in ${!YAMLARRAY[@]} ; do
            echo -en "${INDENT}$(_lgray "\u25B8") $(printf "%-${COL_WIDTH_PERSONS}s" "$(echo "${YAMLARRAY[${i}]}")")"
            echo -en " $(_keyid "$(query_yaml var "${YAML_CONTENT}" "key_user_name" "${YAMLARRAY[${i}]}" "keyid")")"
            echo -e  "   $(_dgray "<$(query_yaml var "${YAML_CONTENT}" "key_user_name" "${YAMLARRAY[${i}]}" "email")>")"
        done
    elif ${LIST_EMAIL} ; then
        yaml2array YAMLARRAY var "${YAML_CONTENT}" "email"
        filter_array "${FILTER_LIST}" YAMLARRAY "${FILTER_EXPR}"
        for i in ${!YAMLARRAY[@]} ; do
            echo -en "${INDENT}$(_lgray "\u25B8") $(_dgray "$(printf "%-${COL_WIDTH_EMAIL}s" "<${YAMLARRAY[${i}]}>")")"
            echo -en " $(printf "%-${COL_WIDTH_PERSONS}s" "$(query_yaml var "${YAML_CONTENT}" "key_user_email" "${YAMLARRAY[${i}]}" "name")")"
            echo -e " $(_keyid "$(query_yaml var "${YAML_CONTENT}" "key_user_email" "${YAMLARRAY[${i}]}" "keyid")")"
        done
    elif ${LIST_GROUPS} ; then
        yaml2array YAMLARRAY var "${YAML_CONTENT}" "groups"
        filter_array "${FILTER_LIST}" YAMLARRAY "${FILTER_EXPR}"
        for i in ${!YAMLARRAY[@]} ; do
            echo -e "${INDENT}$(_lgray "\u25BA") $(_dgray "»${YAMLARRAY[${i}]}«")"
            yaml2array YAMLGROUPMEMBERS var "${YAML_CONTENT}" "members" "${YAMLARRAY[${i}]}"
            for j in ${!YAMLGROUPMEMBERS[@]} ; do
                list_yaml "${YAML_CONTENT}" "p" "${INDENT}    " "${YAMLGROUPMEMBERS[${j}]}"
            done
            unset YAMLGROUPMEMBERS
        done
    elif ${LIST_STORES} ; then
        yaml2array YAMLARRAY var "${YAML_CONTENT}" "stores"
        filter_array "${FILTER_LIST}" YAMLARRAY "${FILTER_EXPR}"
        for i in ${!YAMLARRAY[@]} ; do
            if ${STORE_NAMES_ONLY} ; then
                echo "${YAMLARRAY[${i}]}"
            else
                echo -e "\n${INDENT}$(_lgray "\u25A0") $(_bold "»${YAMLARRAY[${i}]}«")"
                echo -e "${INDENT}  path: $(path_exists -d "${STORE_ROOT_DIR}/$(query_yaml var "${YAML_CONTENT}" "store_name" "${YAMLARRAY[${i}]}" "path")" created)"
                if ! ${SHORT_LIST} ; then
                    echo -e "${INDENT}  $(_brown "defaults for password generation:")\n${INDENT}    $(_dgray "\u2736") length: $(_dgray "$(query_yaml var "${YAML_CONTENT}" "store_name" "${YAMLARRAY[${i}]}" "pw_length")")"
                    echo -e "${INDENT}    $(_dgray "\u2736") characters: $(_dgray "$(query_yaml var "${YAML_CONTENT}" "store_name" "${YAMLARRAY[${i}]}" "pw_chars")")"
                    echo -e "${INDENT}  $(_green "read passwords"):"
                    yaml2array YAMLSTOREREAD var "${YAML_CONTENT}" "access" "${YAMLARRAY[${i}]}" "read"
                    for j in ${!YAMLSTOREREAD[@]} ; do
                        list_yaml "${YAML_CONTENT}" "g" "${INDENT}    " "${YAMLSTOREREAD[${j}]}"
                    done
                    echo -e "${INDENT}  $(_purple "sign key IDs"):"
                    yaml2array YAMLSTORESIGN var "${YAML_CONTENT}" "access" "${YAMLARRAY[${i}]}" "sign"
                    for k in ${!YAMLSTORESIGN[@]} ; do
                        list_yaml "${YAML_CONTENT}" "g" "${INDENT}    " "${YAMLSTORESIGN[${k}]}"
                    done
                    unset YAMLSTOREREAD
                    unset YAMLSTORESIGN
                fi
            fi
        done
    elif ${LIST_PW_FROM_RW_STORE} ; then
        readarray -t -d '' "GPGID_FILES_IN_RW_STORE" < <(find "${RW_STORE}" -type f -name ".gpg-id" -print0 | sort -z)
        filter_array "${FILTER_LIST}" GPGID_FILES_IN_RW_STORE "${FILTER_EXPR}"
        yaml2array YAMLARRAY_KEYS var "${YAML_CONTENT}" "keys"
        yaml2array YAMLARRAY_GROUPS var "${YAML_CONTENT}" "groups"
        yaml2array YAMLARRAY_READALL_MEMBERS var "${YAML_CONTENT}" "members" "readall"
        YAMLARRAY_READALL_KEYS=()
        for i in "${YAMLARRAY_READALL_MEMBERS[@]}" ; do
            YAMLARRAY_READALL_KEYS+=($(query_yaml var "${YAML_CONTENT}" "key_user_name" "${i}" "keyid"))
        done
        YAMLARRAY_READALL_KEYS=($(printf "%s\n" "${YAMLARRAY_READALL_KEYS[@]}" | sort -u))
        for i in "${GPGID_FILES_IN_RW_STORE[@]}" ; do
            RW_STORE_DIR="${i%/*}"
            TMP_GPGIDFILE=($(<${i}))
            TMP_GPGIDFILE=($(printf "%s\n" "${TMP_GPGIDFILE[@]}" | sort -u))
            MATCHING_GROUPS=()
            echo -e "\n${INDENT}$(_blue "\u25A3") $(path_exists -d "${RW_STORE_DIR}" show)"
            echo -e "${INDENT}  $(_dgray "keys in .gpg-id file:")"
            compare_key_arrays TMP_GPGIDFILE YAMLARRAY_KEYS "YAML" "all" "${INDENT}  " "${YAML_CONTENT}" "key_user_keyid" "name"
            compare_key_arrays YAMLARRAY_READALL_KEYS TMP_GPGIDFILE ".gpg-id, »readall« key" "miss_purp" "${INDENT}  " "${YAML_CONTENT}" "key_user_keyid" "name"
            # find matching groups
            for j in "${YAMLARRAY_GROUPS[@]}" ; do
                TMP_GROUP_ARRAY=("${j}")
                TMP_GROUP_KEYS=($(groups2keys_array "${YAML_CONTENT}" TMP_GROUP_ARRAY))
                [[ "${TMP_GROUP_KEYS[@]}" == "${TMP_GPGIDFILE[@]}" ]] && MATCHING_GROUPS+=("${j}")
                unset TMP_GROUP_ARRAY
                unset TMP_GROUP_KEYS
            done
            if [[ "${#MATCHING_GROUPS[@]}" -gt 0 ]] ; then
                [[ "${#MATCHING_GROUPS[@]}" -gt 1 ]] \
                    && echo -e "${INDENT}  $(_dgray "matching groups:")" \
                    || echo -e "${INDENT}  $(_dgray "matching group:")"
                for k in "${MATCHING_GROUPS[@]}" ; do
                    echo -e "${INDENT}    $(_lgray "\u25BA") $(_dgray "»${k}«" b)"
                done
            else
                echo -e "${INDENT}  $(_dgray "(no matching groups)")"
            fi
            compare_encryption_to_gpgid "${i}" "${INDENT}" "${FILTER_EXPR2}"
            unset RW_STORE_DIR
            unset TMP_GPGIDFILE
            unset MATCHING_GROUPS
        done
        unset YAMLARRAY_KEYS
        unset YAMLARRAY_GROUPS
        unset YAMLARRAY_READALL_KEYS
        unset GPGID_FILES_IN_RW_STORE
    else
        warning "got nothing to list!"
    fi
}

compare_key_arrays () {
    [[ "$1" =~ ^(-h|--help)$ || "$1" == "" ]] && { 
        echo "checks each item of array1 for availability in array2.

    by default, items are assumed to be key IDs if no alternative mode was set.

    usage: compare_key_arrays [array1] [array2] [name2] [mode] [indent] (yaml) (sel_var) (query)

        [array1]:  name of the first array
        [array2]:  name of the second array
        [name2]:   printable name of the second array
        [mode]:    one of:
                     - \"all\":       show matches and misses
                     - \"miss_red\":  show only misses, in red
                     - \"miss_purp\": show only misses, in purple
                     - \"paths\":     items are paths, not key IDs
        [indent]:  spaces to indent results
        (yaml):    optional content of the YAML file
        (sel_var): optional sel_var (see query_yaml)
        (query):   optional query (see query_yaml)
        ";
        return
    };
    [[ "$1" =~ ^(-v|--version)$ ]] && { 
        echo "1";
        return
    };
    declare -n ARRAY1=$1;
    declare -n ARRAY2=$2;
    local NAME2="$3";
    local MODE_ALL=false;
    local MISS_PURP=false;
    local MODE_PATHS=false;
    case "$4" in
        all) MODE_ALL=true >&2
             ;;
        miss_red)
             MODE_ALL=false >&2
             ;;
        miss_purp)
             MISS_PURP=true >&2
             ;;
        paths)
             MODE_PATHS=true >&2
             ;;
        *) error "invalid mode!"
             ;;
    esac
    local INDENT="$5"
    local YAML="$6";
    local SEL_VAR="$7";
    local QUERY="$8";
    local DO_QUERY=false;
    local QUERY_RES="";
    [[ "${YAML}" != "" ]] && [[ "${SEL_VAR}" != "" ]] && [[ "${QUERY}" != "" ]] && DO_QUERY=true
    local i;
    for i in "${ARRAY1[@]}" ; do
        if ${DO_QUERY} ; then
            QUERY_RES="$(query_yaml var "${YAML}" "${SEL_VAR}" "${i}" "${QUERY}")"
            [[ "${QUERY_RES}" != "" ]] && QUERY_RES+=" "
        fi
        if ${MODE_ALL} ; then
            [[ " ${ARRAY2[@]} " =~ " ${i} " ]] \
                && echo -e "${INDENT}[$(_green "\u2714")] $(_keyid "${i}") $(_info "${QUERY_RES}")" \
                || echo -e "${INDENT}[$(_red "\u2716")] $(_red "${i}" b) $(_info "${QUERY_RES}(missing in ${NAME2})")"
        elif ${MODE_PATHS} ; then
            [[ " ${ARRAY2[@]} " =~ " ${i} " ]] \
                && echo -e "${INDENT}[$(_green "\u2714")] $(_green "${i}")" \
                || echo -e "${INDENT}[$(_red "\u2716")] $(_red "${i}" b) $(_info "(missing in ${NAME2})")"
        elif ${MISS_PURP} ; then
            [[ " ${ARRAY2[@]} " =~ " ${i} " ]] \
                || echo -e "${INDENT}[$(_purple "\u26A0")] $(_purple "${i}" b) $(_info "${QUERY_RES}${XSPC}(missing in ${NAME2})")"
        else
            [[ " ${ARRAY2[@]} " =~ " ${i} " ]] \
                || echo -e "${INDENT}[$(_red "\u2716")] $(_red "${i}" b) $(_info "${QUERY_RES}${XSPC}(missing in ${NAME2})")"
        fi
        unset QUERY_RES
    done
}

compare_encryption_to_gpgid () {
    [[ "$1" =~ ^(-h|--help)$ || "$1" == "" ]] && { 
        echo "takes a .gpg-id file name, looks for *.gpg files in
the same directory and tries to match the keys in .gpg-id with
the keys the files were encrypted for.

    usage: compare_encryption_to_gpgid [gpgid] (indent) (regexp)

        [gpgids]: full path to a .gpg-id file
        (indent): extra indent space
        (regexp): optional regular expression to filter password files
        ";
        return
    };
    [[ "$1" =~ ^(-v|--version)$ ]] && { 
        echo "1";
        return
    };

    local GPGID_FILE_IN_STORE="$1";
    local STORE_DIR="${GPGID_FILE_IN_STORE%/*}"
    local TMP_GPGIDFILE=($(<${GPGID_FILE_IN_STORE}))
    local INDENT="$2"
    local FILTER_EXPR="$3"
    local FILTER_LIST=false;
    [[ "${FILTER_EXPR}" != "" ]] && FILTER_LIST=true
    local i;
    TMP_GPGIDFILE=($(printf "%s\n" "${TMP_GPGIDFILE[@]}" | sort -u))
    readarray -t -d '' "GPG_FILES_IN_STORE" < <(find "${STORE_DIR}" -mindepth 1 -maxdepth 1 -type f -name "*.gpg" -print0 | sort -uz)
    filter_array "${FILTER_LIST}" GPG_FILES_IN_STORE "${FILTER_EXPR}"
    if [[ "${#GPG_FILES_IN_STORE[@]}" -gt 0 ]] ; then
        echo -e "${INDENT}  $(_blue "\u25A3") $(_path "${STORE_DIR}")"
        [[ "${#GPG_FILES_IN_STORE[@]}" -gt 1 ]] \
            && echo -e "${INDENT}    $(_dgray "password files:")" \
            || echo -e "${INDENT}    $(_dgray "password file:")"
        for i in "${GPG_FILES_IN_STORE[@]}" ; do
            readarray -t -d '' "FILE_ENCRYPTED_FOR" < <(gpg --status-fd 1 --pinentry-mode cancel --list-packets "${i}" 2> /dev/null | grep "KEY_CONSIDERED" | sort -u | cut -d " " -f 3)
            FILE_ENCRYPTED_FOR=($(printf "%s\n" "${FILE_ENCRYPTED_FOR[@]}" | sort -u))
            echo -e "${INDENT}    - $(path_exists -f "${i}" show)"
            compare_key_arrays TMP_GPGIDFILE FILE_ENCRYPTED_FOR "encrypted file" "all" "      " "${YAML_CONTENT}" "key_user_keyid" "name"
            compare_key_arrays FILE_ENCRYPTED_FOR TMP_GPGIDFILE ".gpg-id" "miss_red" "      " "${YAML_CONTENT}" "key_user_keyid" "name"
        done
    else
        echo -e "${INDENT}  [$(_purple "\u26A0")] $(_purple "${STORE_DIR}") $(_info "no encrypted files")"
    fi
    unset STORE_DIR
    unset TMP_GPGIDFILE
    unset GPG_FILES_IN_STORE
    unset FILE_ENCRYPTED_FOR
}


compare_gpgid_to_yaml () {
    [[ "$1" =~ ^(-h|--help)$ || "$1" == "" ]] && { 
        echo "compares a .gpg-id file name with YAML content.

    usage: compare_gpgid_to_yaml [gpgid] [yaml] [dirs] [root] [mode] (yconf) (skeys)

        [gpgids]: full path to a .gpg-id file
        [yaml]:   the YAML content
        [dirs]:   array with valid directory names
        [root]:   the store root directory
        [mode]:   one of:
                    - \"keys\": check if keys are defined in YAML
                    - \"sigs\":  check if signatures match YAML keys
        (yconf):  if [mode] is \"sigs\", the YAML config file to check its signature
        (skeys):  if [mode] is \"sigs\", an array with valid signature key IDs
        ";
        return
    };
    [[ "$1" =~ ^(-v|--version)$ ]] && { 
        echo "1";
        return
    };

    local GPGID_FILE_IN_STORE="$1";
    local YAML_CONTENT="$2";
    declare -n DIRS="$3";
    local STOREROOT="$4";
    local CHECK_KEYS=false;
    local CHECK_SIGS=false;
    local YAML_CONF=""
    case "$5" in
        keys) CHECK_KEYS=true >&2
             ;;
        sigs) CHECK_SIGS=true >&2
              YAML_CONF="$6" >&2
              declare -n SIGN_KEY_IDS="$7";
             ;;
        *) error "invalid mode!"
             ;;
    esac
    local i
    local j

    if [[ " ${DIRS[@]} " =~ " ${GPGID_FILE_IN_STORE%/.gpg-id} " ]] || [[ "${YAML_CONF}" == "${GPGID_FILE_IN_STORE}" ]] ; then
        if ${CHECK_KEYS} ; then
            local REL_FILE_GPGID="${GPGID_FILE_IN_STORE#${STOREROOT}/}"
            local REL_DIR_GPGID="${REL_FILE_GPGID%/*}"
            if [[ "${REL_DIR_GPGID}" == ".gpg-id" ]] ; then
                # if we're dealing with the store root directory, fix the value
                # yaml2array will deal with this edge case
                REL_DIR_GPGID=""
            fi
            yaml2array RO_STORE_GROUPS_GPGID var "${YAML_CONTENT}" "access" "${REL_DIR_GPGID}" "path2read"
            local RO_STORE_KEYIDS_GPGID=($(groups2keys_array "${YAML_CONTENT}" RO_STORE_GROUPS_GPGID))
            local TMP_GPGIDFILE=($(<${GPGID_FILE_IN_STORE}))
            echo -e "  $(_blue "\u25A3") $(_path "${GPGID_FILE_IN_STORE}")"
            compare_key_arrays TMP_GPGIDFILE RO_STORE_KEYIDS_GPGID "YAML" "all" "    " "${YAML_CONTENT}" "key_user_keyid" "name"
            # also check if there's missing keys
            compare_key_arrays RO_STORE_KEYIDS_GPGID TMP_GPGIDFILE ".gpg-id" "miss_purp" "    " "${YAML_CONTENT}" "key_user_keyid" "name"
            unset RO_STORE_GROUPS_GPGID
        elif ${CHECK_SIGS} ; then
            for i in ${GPGID_FILE_IN_STORE[@]} ; do
                if [[ -f "${i}.sig" ]] ; then
                    # is there a more elegant solution than calling gpg twice to fetch key ID?
                    # the second call contains both KEY_CONSIDERED and either GOODSIGN or BADSIGN
                    readarray -t -d '' "SIGS_IN_GPGID" < <(gpg --verify "${i}.sig" "${i}" 2> /dev/null && gpg --status-fd 1 --verify "${i}.sig" "${i}" 2> /dev/null | grep "KEY_CONSIDERED" | sort -u | cut -d " " -f 3)
                    VALID_SIGNATURE=false
                    for j in "${SIGS_IN_GPGID[@]}" ; do
                        if [[ " ${SIGN_KEY_IDS[@]} " =~ " ${j//$'\n'/} " ]] ; then
                            VALID_SIGNATURE=true
                        fi
                    done
                    ${VALID_SIGNATURE} \
                        && echo -e "  [$(_green "\u2714")] $(_green "${i}")" \
                        || echo -e "  [$(_red "\u2716")] $(_red "${i}" b) $(_info "invalid sigature")"
                    unset VALID_SIGNATURE
                    unset SIGS_IN_GPGID
                else
                    echo -e "  [$(_red "\u2716")] $(_red "${i}" b) $(_info "no sigature")"
                fi
            done
        else
            error "missing something to do! wrong call?"
        fi
    else
        echo -e "  $(_red "\u25A3") $(_red "${GPGID_FILE_IN_STORE}" b)"
        echo -e "    [$(_red "\u2716")] $(_info "undefined password store")"
    fi
}

# read the YAML file into a variable so we don't have to read the
# file each time the script needs to filter something from it
YAML_CONTENT=$(<${STORE_YAML})
# create some arrays in advance, once
if ${HAVE_STORE_NAME} || ${INTEGRITYCHECKS_RO} || ${INTEGRITYCHECKS_RW} ; then
    yaml2array YAMLARRAY_STORES var "${YAML_CONTENT}" "stores"
fi
if ${MOVE_PASSWORD} || ${SYNC_PASSWORD} || ${GENERATE_PASSWORD_RO} || ${GENERATE_PASSWORD_RW} || ${UPDATE_RO_STORE} || ${UPDATE_RW_STORE} ; then
    yaml2array YAMLARRAY_STOREREAD var "${YAML_CONTENT}" "access" "${STORE_NAME}" "read"
fi
# validate the store name
if ${HAVE_STORE_NAME} ; then
    [[ " ${YAMLARRAY_STORES[@]} " =~ " ${STORE_NAME} " ]] \
        || error "invalid store name: $(_blue "${STORE_NAME}")!"
fi


##
## BEGIN integrity checks
##
if ${INTEGRITYCHECKS_RO} || ${INTEGRITYCHECKS_RW} ; then
    ${INTEGRITYCHECKS_RO} \
        && STORE_ROOT_DIR="${STORE_RO}" \
        || STORE_ROOT_DIR="${STORE_RW}"
    ${INTEGRITYCHECKS_RO} \
        && STORE_ROOT_TYPE="read-only" \
        || STORE_ROOT_TYPE="writable"
    echo -e "$(_orange "checking" bu)$(_orange ": are all directories in the ${STORE_ROOT_TYPE} location defined in YAML store conf?")"
        readarray -t -d " " SIGNKEYS_IN_CONF < <(echo -n "${SIGN_KEYS}")
        readarray -t -d " " PERSONAL_SIGNKEYS_IN_CONF < <(echo -n "${PERSONAL_SIGN_KEYS}")
        YAMLARRAY_PASSADMINS=("passadmin")
        YAMLARRAY_PASSADMINKEYS=($(groups2keys_array "${YAML_CONTENT}" YAMLARRAY_PASSADMINS))
        # fetch all paths. we'll initialize the array with the config dir to avoid false alarms
        DIRS_IN_YAML=("${STORE_YAML%/*}")
        # now add all stores configured in the YAML file
        for i in ${!YAMLARRAY_STORES[@]} ; do
            DIRS_IN_YAML+=("${STORE_ROOT_DIR}/$(query_yaml var "${YAML_CONTENT}" "store_name" "${YAMLARRAY_STORES[${i}]}" "path")")
        done
        DIRS_IN_YAML=($(echo "${DIRS_IN_YAML[@]%/}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
        # read directories in array
        # "-links 2" only includes directories with two hardlinks, effectively resulting
        # in only including the deepest directory, not all parents
        dir_array DIRS_IN_STORE_ROOT_DEEP "${STORE_ROOT_DIR}" "-links 2"
        compare_key_arrays DIRS_IN_STORE_ROOT_DEEP DIRS_IN_YAML "YAML" "paths" "  "
        unset DIRS_IN_STORE_ROOT_DEEP
        echo ""
    ${INTEGRITYCHECKS_RO} && {
        echo -e "$(_orange "checking" bu)$(_orange ": do signing keys match (YAML passadmin == local config file)?")"
            echo -e "  personal signing keys:"
            compare_key_arrays PERSONAL_SIGNKEYS_IN_CONF YAMLARRAY_PASSADMINKEYS "YAML" "all" "  " "${YAML_CONTENT}" "key_user_keyid" "name"
            echo -e "  all signing keys:"
            compare_key_arrays SIGNKEYS_IN_CONF YAMLARRAY_PASSADMINKEYS "YAML" "all" "  " "${YAML_CONTENT}" "key_user_keyid" "name"
            compare_key_arrays YAMLARRAY_PASSADMINKEYS SIGNKEYS_IN_CONF "local config" "miss_red" "  " "${YAML_CONTENT}" "key_user_keyid" "name"
            echo ""
    }
    echo -e "$(_orange "checking" bu)$(_orange ": do all directories with password files have a direct .gpg-id file?")"
        dir_array DIRS_IN_STORE_ROOT "${STORE_ROOT_DIR}"
        readarray -t "DIRS_WITH_ENCFILES_IN_STORE_ROOT" < <(find "${STORE_ROOT_DIR}" -type f -name "*.gpg")
        DIRS_WITH_ENCFILES_IN_STORE_ROOT=($(printf "%s\n" "${DIRS_WITH_ENCFILES_IN_STORE_ROOT[@]%/*}" | sort -u))
        for i in "${DIRS_WITH_ENCFILES_IN_STORE_ROOT[@]}" ; do
            if [[ " ${DIRS_IN_STORE_ROOT[@]} " =~ " ${i} " ]] ; then
                [[ -f "${i}/.gpg-id" ]] \
                    && echo -e "  [$(_green "\u2714")] $(_green "${i}")" \
                    || echo -e "  [$(_purple "\u26A0")] $(_purple "${i}") $(_info "no .gpg-id found")"
            else
                echo -e "  $(_red "\u25A3") $(_red "${i}" b)"
                echo -e "    [$(_red "\u2716")] $(_info "undefined password store")"
            fi
        done
        unset DIRS_WITH_ENCFILES_IN_STORE_ROOT
        echo ""
    readarray -t -d '' "GPGID_FILES_IN_STORE_ROOT" < <(find "${STORE_ROOT_DIR}" -type f -name ".gpg-id" -print0 | sort -z)
    ${INTEGRITYCHECKS_RO} && {
        echo -e "$(_orange "checking" bu)$(_orange ": do all .gpg-id files and YAML file have a valid signature?")"
            for i in "${GPGID_FILES_IN_STORE_ROOT[@]}" "${STORE_YAML}" ; do
                compare_gpgid_to_yaml "${i}" "${YAML_CONTENT}" DIRS_IN_YAML "${STORE_ROOT_DIR}" "sigs" "${STORE_YAML}" YAMLARRAY_PASSADMINKEYS
            done
            echo ""
    }
    echo -e "$(_orange "checking" bu)$(_orange ": do keys in .gpg-id files match YAML store configuration?")"
        # use the list of defined store directories to know all expected .gpg-id files
        for i in "${GPGID_FILES_IN_STORE_ROOT[@]}" ; do
            compare_gpgid_to_yaml "${i}" "${YAML_CONTENT}" DIRS_IN_YAML "${STORE_ROOT_DIR}" "keys"
        done
        echo ""
    echo -e "$(_orange "checking" bu)$(_orange ": does password encryption match keys in .gpg-id files?")"
        for i in "${GPGID_FILES_IN_STORE_ROOT[@]}" ; do
            compare_encryption_to_gpgid "${i}"
        done
        echo ""
    exit 0
fi
##
## END integrity checks
##


##
## BEGIN list info
##
if ${FILTERCONF} ; then
    if ${LIST_KEYS} ; then
        echo -e "\nall configured OpenPGP key IDs:"
        list_yaml "${YAML_CONTENT}" "k" "  " "${FILTER_EXPR}"
    elif ${LIST_PERSONS} ; then
        echo -e "\nall persons with an OpenPGP key ID:"
        list_yaml "${YAML_CONTENT}" "p" "  " "${FILTER_EXPR}"
    elif ${LIST_EMAIL} ; then
        echo -e "\nall e-mail addresses with an OpenPGP key ID:"
        list_yaml "${YAML_CONTENT}" "e" "  " "${FILTER_EXPR}"
    elif ${LIST_GROUPS} ; then
        echo -e "\nall configured groups:"
        list_yaml "${YAML_CONTENT}" "g" "  " "${FILTER_EXPR}"
    elif ${LIST_STORES} ; then
        if ${STORE_NAMES_ONLY} ; then
            list_yaml "${YAML_CONTENT}" "N" "  " "${FILTER_EXPR}"
        else
            echo -e "\nall configured stores:"
            ${SHORT_LIST} \
                && list_yaml "${YAML_CONTENT}" "S" "  " "${FILTER_EXPR}" \
                || list_yaml "${YAML_CONTENT}" "s" "  " "${FILTER_EXPR}"
        fi
    elif ${LIST_PW_FROM_RW_STORE} ; then
        echo -e "\nall password stores found in the writable location:"
        list_yaml "${YAML_CONTENT}" "r" "  " "${FILTER_EXPR}" "${STORE_RW}"
    else
        warning "got nothing to list!"
    fi
    echo -en "\n"
fi
##
## END list info
##


if ${MOVE_PASSWORD} || ${SYNC_PASSWORD} || ${GENERATE_PASSWORD_RO} || ${GENERATE_PASSWORD_RW} ; then
    TARGET_REL_DIR="$(query_yaml var "${YAML_CONTENT}" "store_name" "${STORE_NAME}" "path")"
    ${GENERATE_PASSWORD_RW} \
        && TARGET_DIR="${STORE_RW}/${TARGET_REL_DIR}" \
        || TARGET_DIR="${STORE_RO}/${TARGET_REL_DIR}"
fi


##
## BEGIN sync password
##
if ${SYNC_PASSWORD} ; then
    # find all .gpg files in RW store
    SOURCE_DIR="${STORE_RW}/${TARGET_REL_DIR}"
    ! [[ -d "${SOURCE_DIR}" ]] \
        && error "directory does not exist:\n  $(_red "${SOURCE_DIR}" b)"
    readarray -t -d '' "GPG_FILES_IN_SOURCE_DIR" < <(find "${SOURCE_DIR}" -mindepth 1 -maxdepth 1 -type f -name "*.gpg" -print0 | sort -uz)
    # now simply call passtore.sh -m for each file found
    for i in "${GPG_FILES_IN_SOURCE_DIR[@]}" ; do
        passtore.sh -p "${CONFPROFILE}" -s "${STORE_NAME}" -m "${i#${STORE_RW}/}"
    done
    unset GPG_FILES_IN_SOURCE_DIR
    exit 0
fi
##
## END sync password
##


##
## BEGIN move password, stage 1
##
if ${MOVE_PASSWORD} ; then
    echo -e "\nmoving password file:"
    PW_IN_RW_STORE="${STORE_RW}/${RW_PW_FILE#/}"
    DIR_IN_RW_STORE="${PW_IN_RW_STORE%/*}"
    GPGID_IN_RW_STORE="${DIR_IN_RW_STORE}/.gpg-id"
    ! [[ -d "${DIR_IN_RW_STORE}" ]] \
        && error "directory does not exist:\n  $(_red "${DIR_IN_RW_STORE}" b)"
    ! [[ -f "${PW_IN_RW_STORE}" ]] \
        && error "file does not exist:\n  [$(_red "\u2716")] $(_red "${PW_IN_RW_STORE}" b)"
    ! [[ -f "${GPGID_IN_RW_STORE}" ]] \
        && error "file does not exist:\n  [$(_red "\u2716")] $(_red "${GPGID_IN_RW_STORE}" b)"

    echo -en "\n  $(_underscore "source store"):"
    list_yaml "${YAML_CONTENT}" "r" "    " "${DIR_IN_RW_STORE}" "${STORE_RW}" "${RW_PW_FILE}"

    echo -en "\n  $(_underscore "target store"):"
    list_yaml "${YAML_CONTENT}" "s" "    " "^${STORE_NAME}$"

    echo -e "\n  $(_underscore "key match"):"
    echo -e "    $(_dgray "comparing key IDs in .gpg-id with groups in store configuration:")"
    KEYMATCH=($(groups2keys_array "${YAML_CONTENT}" YAMLARRAY_STOREREAD))
    TMP_GPGIDFILE=($(<${GPGID_IN_RW_STORE}))
    TMP_GPGIDFILE=($(printf "%s\n" "${TMP_GPGIDFILE[@]}" | sort -u))

    compare_key_arrays TMP_GPGIDFILE KEYMATCH "YAML" "all" "    " "${YAML_CONTENT}" "key_user_keyid" "name"
    compare_key_arrays KEYMATCH TMP_GPGIDFILE ".gpg-id" "miss_purp" "    " "${YAML_CONTENT}" "key_user_keyid" "name"    

    if [[ -f "${TARGET_DIR}/${RW_PW_FILE##*/}" ]] ; then
        echo -e "\n  $(warning "the target file $(_bold "already exists"), if you proceed it will be $(_bold "replaced!")")"
        Q_PREFIX="overwrite $(_red "existing") $(_orange "password file in" b)"
    else
        Q_PREFIX="move password file to"
    fi

    PROCEED=$(yesno "\n  $(_orange "${Q_PREFIX} target store directory:" b)\n    $(_dgray "\u27A4") $(_path "${TARGET_DIR}/")$(_purple "${RW_PW_FILE##*/}" b)\n\n  $(_bold "proceed?")")
    if ${PROCEED} ; then
        UPDATE_RO_STORE=true
        XTRA_SPACE="  "
        echo ""
    else
        MOVE_PASSWORD=false
        _red "\n  aborted!\n" b
        exit 0
    fi
    unset PROCEED
fi
##
## END move password, stage 1
## initialize password store first
##


##
## BEGIN generate password, stage 1
##
if ${GENERATE_PASSWORD_RO} || ${GENERATE_PASSWORD_RW} ; then
    echo -e "\ngenerate new password:"
    NEW_PW_FILE_GPG="${TARGET_DIR}/${NEW_PW_FILE}.gpg"

    echo -en "\n  $(_underscore "target store"):"
    ${GENERATE_PASSWORD_RO} \
        && list_yaml "${YAML_CONTENT}" "s" "    " "${STORE_NAME}" \
        || list_yaml "${YAML_CONTENT}" "s" "    " "${STORE_NAME}" "" "" "${STORE_RW}"

    if ${MANUAL_PW_CHARS} || ${MANUAL_PW_LENGTH} ; then
        [[ "${PASSWORD_STORE_CHARACTER_SET}" == "" ]] \
            && PASSWORD_STORE_CHARACTER_SET="$(query_yaml var "${YAML_CONTENT}" "store_name" "${STORE_NAME}" "pw_chars")" \
            || PW_CHARS_ADJUSTED="\n    $(_dgray "\u2736") $(_bold "characters:") $(_dgray "${PASSWORD_STORE_CHARACTER_SET}")"
        [[ "${PASSWORD_LENGTH}" == "" ]] \
            && PASSWORD_LENGTH="$(query_yaml var "${YAML_CONTENT}" "store_name" "${STORE_NAME}" "pw_length")" \
            || PW_LENGTH_ADJUSTED="\n    $(_dgray "\u2736") $(_bold "length:") $(_dgray "${PASSWORD_LENGTH}")"
            echo -e "\n  $(_underscore "manual adjustments to password defaults"):${PW_LENGTH_ADJUSTED}${PW_CHARS_ADJUSTED}"
    fi
    
    if [[ -f "${NEW_PW_FILE_GPG}" ]] ; then
        echo -e "\n  $(warning "the target file $(_bold "already exists"), if you proceed it will be $(_bold "replaced!")")"
        Q_PREFIX="$(_orange "overwrite" b) $(_red "existing")"
        PASS_GEN_OPTIONS="--in-place ${PASS_GEN_OPTIONS}"
    else
        Q_PREFIX="$(_orange "generate" b) $(_green "new" b)"
    fi

    PROCEED=$(yesno "\n  ${Q_PREFIX} $(_orange "password file in target store directory:" b)\n    $(_dgray "\u27A4") $(_path "${TARGET_DIR}/")$(_purple "${NEW_PW_FILE}.gpg" b)\n\n  $(_bold "proceed?")")
    if ${PROCEED} ; then
        ${GENERATE_PASSWORD_RO} \
            && UPDATE_RO_STORE=true \
            && UPDATE_RW_STORE=true
        XTRA_SPACE="  "
        echo ""
    else
        GENERATE_PASSWORD_RO=false
        GENERATE_PASSWORD_RW=false
        _red "\n  aborted!\n" b
        exit 0
    fi
    unset PROCEED
fi
##
## END generate password, stage 1
## initialize password store first
##


##
## BEGIN update store
##
if ${UPDATE_RO_STORE} || ${UPDATE_RW_STORE} ; then
    STORE_DIR_REL="$(query_yaml var "${YAML_CONTENT}" "store_name" "${STORE_NAME}" "path")"
    ${UPDATE_RO_STORE} \
        && STORE_ROOT_DIR="${STORE_RO}" \
        || STORE_ROOT_DIR="${STORE_RW}"
    ${UPDATE_RO_STORE} \
        && STORE_ROOT_TYPE="read-only" \
        || STORE_ROOT_TYPE="writable"
    STORE_DIR="${STORE_ROOT_DIR}/${STORE_DIR_REL}"
    [[ -d "${STORE_DIR}" ]] \
        && echo -e "${XTRA_SPACE}$(_orange "updating" b) password store $(_bold "${STORE_NAME}")" \
        || echo -e "${XTRA_SPACE}$(_green "initializing" b) password store $(_bold "${STORE_NAME}")"
    # only proceed if ${STORE_ROOT_DIR} exists
    [[ -d "${STORE_ROOT_DIR}" ]] \
        && echo -e "${XTRA_SPACE}  $(_info "- ${STORE_ROOT_TYPE} store:") $(path_exists -d "${STORE_ROOT_DIR}" show)" \
        || error "the ${STORE_ROOT_TYPE} store root directory does not exist: $(path_exists -d "${STORE_ROOT_DIR}" show)"
    mkmissingdir "${STORE_DIR}"

    echo -e "${XTRA_SPACE}    $(_green "read passwords"):"
    STORE_READ_ACCESS_KEYIDS=()
    for j in ${!YAMLARRAY_STOREREAD[@]} ; do
        echo -e "${XTRA_SPACE}      - $(_dgray "»${YAMLARRAY_STOREREAD[${j}]}«")"
        yaml2array YAMLGROUPMEMBERS var "${YAML_CONTENT}" "members" "${YAMLARRAY_STOREREAD[${j}]}"
        for l in ${!YAMLGROUPMEMBERS[@]} ; do
            USER_KEYID="$(query_yaml var "${YAML_CONTENT}" "key_user_name" "${YAMLGROUPMEMBERS[${l}]}" "keyid")"
            STORE_READ_ACCESS_KEYIDS+=(${USER_KEYID})
            echo -en "${XTRA_SPACE}          - $(printf "%-${COL_WIDTH_PERSONS}s" "$(echo "${YAMLGROUPMEMBERS[${l}]}")")"
            echo -en " $(_keyid "${USER_KEYID}")"
            echo -e  "   $(_dgray "<$(query_yaml var "${YAML_CONTENT}" "key_user_name" "${YAMLGROUPMEMBERS[${l}]}" "email")>")"
            unset USER_KEYID
        done
        unset YAMLGROUPMEMBERS
    done
    # make key IDs unique and sorted
    STORE_READ_ACCESS_KEYIDS=($(echo "${STORE_READ_ACCESS_KEYIDS[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

    echo -en "${XTRA_SPACE}  ${TXT_DGRAY}- "
    #PASSWORD_STORE_GPG_OPTS="--homedir ${GPGHOME}" \
    PASSWORD_STORE_SIGNING_KEY="${PERSONAL_SIGN_KEYS}" \
    PASSWORD_STORE_DIR="${STORE_ROOT_DIR}" \
    pass init --path="${STORE_DIR_REL}" "${STORE_READ_ACCESS_KEYIDS[@]}"
    echo -e "${OFF}"
fi
##
## END update store
##


##
## BEGIN move password, stage 2
##
if ${MOVE_PASSWORD} ; then
    echo -en "  moving $(_path "${PW_IN_RW_STORE}") to $(_path "${TARGET_DIR}")..."
    mv "${PW_IN_RW_STORE}" "${TARGET_DIR}" || error "unable to move file!"
    alldone
    exit 0
fi
##
## END move password, stage 2
##

##
## BEGIN generate password, stage 2
##
if ${GENERATE_PASSWORD_RO} || ${GENERATE_PASSWORD_RW} ; then
    ${GENERATE_PASSWORD_RO} \
        && PW_STORE_DIR="${STORE_RO}" \
        || PW_STORE_DIR="${STORE_RW}"
    echo -en "    ${TXT_DGRAY}- "
    PASSWORD_STORE_SIGNING_KEY="${PERSONAL_SIGN_KEYS}" \
    PASSWORD_STORE_DIR="${PW_STORE_DIR}" \
    PASSWORD_STORE_CHARACTER_SET="${PASSWORD_STORE_CHARACTER_SET}" \
    pass generate ${PASS_GEN_OPTIONS} "${TARGET_REL_DIR}/${NEW_PW_FILE}" ${PASSWORD_LENGTH}
    echo -e "${OFF}"
    exit 0
fi
##
## END generate password, stage 2
##


if ${IMPORTKEYS} || ${FETCHKEY} ; then
    mkmissingdir "${GPGHOME}" "none" "0700"
fi


##
## BEGIN import keys
##
if ${IMPORTKEYS} ; then
    ALLASCKEYS+=$(ls "${ASCROOT}/"*.asc)
    if [[ ${#ALLASCKEYS[@]} -gt 0 ]] ; then
        for k in ${ALLASCKEYS[@]} ; do
            echo -en "importing key $(_blue "$k")..."
            gpg --homedir "${GPGHOME}" \
                --quiet \
                --import "$k" || error "import failed!"
            alldone
        done
    else
        error "no keys found in $(_blue "${ASCROOT}/*.asc")!"
    fi
    unset ALLASCKEYS
elif ${IMPORTKEYS_WKD} ; then
    yaml2array YAML_ALL_EMAIL var "${YAML_CONTENT}" "email"
    echo -e "\nimporting keys from WKD to $(_path "${GPGHOME}"):"
    for i in ${YAML_ALL_EMAIL[@]} ; do
        echo -en "  $(_lgray "\u25B8") $(_dgray "$(printf "%-${COL_WIDTH_EMAIL}s" "<${i}>")")"
        FETCHED_KEY="$(
            gpg --homedir "${GPGHOME}" \
                --quiet \
                --status-fd 1 \
                --auto-key-locate clear,wkd,nodefault \
                --locate-external-keys "${i}" 2> /dev/null \
                | grep "KEY_CONSIDERED" | cut -d " " -f 3
        )"
        [[ "${FETCHED_KEY}" == "" ]] \
            && echo -e " $(_red "failed!" b)" \
            || {
                echo -en " ($(_keyid "${FETCHED_KEY}"))"
                alldone
            }
    done
    unset i
    unset YAML_ALL_EMAIL
elif ${FETCHKEY} ; then
    gpg --homedir "${GPGHOME}" \
        --auto-key-locate clear,wkd,nodefault \
        --locate-external-keys "${PATTERN}"
fi
##
## END import keys
##

### END SCRIPT BODY ###

exit 0
