
; Project version from setup.xml:
; PROJECT_VERSION                   "${PROJECT_VERSION}"
; PROJECT_VERSION_MAJOR             "${PROJECT_VERSION_MAJOR}"
; PROJECT_VERSION_MINOR             "${PROJECT_VERSION_MINOR}"
; PROJECT_VERSION_MICRO             "${PROJECT_VERSION_MICRO}"

; Based on commit hash/tag name:
; PROJECT_VERSION_VCS               "${PROJECT_VERSION_VCS}"
; PROJECT_VERSION_VCS_LONG          "${PROJECT_VERSION_VCS_LONG}"
; PROJECT_VERSION_VCS_SYSTEM        "${PROJECT_VERSION_VCS_SYSTEM}"
; PROJECT_VERSION_VCS_VERSION       "${PROJECT_VERSION_VCS_VERSION}"

#define ProjectVersion     "${PROJECT_VERSION}"

#define AppName "netX Tag List Editor/NXO Builder"
#define AppVersion "${PROJECT_VERSION_VCS_VERSION}"
#define AppVerName AppName+" "+AppVersion
#define InstallerName "tag_list_editor_"+AppVersion+"_setup"
