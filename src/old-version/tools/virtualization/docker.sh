#!/usr/bin/env bash
##########################
tmoe_docker_init() {
    if [ ! "$(pgrep docker)" ]; then
        service docker start 2>/dev/null || systemctl start docker
    else
        docker stop ${CONTAINER_NAME} 2>/dev/null
    fi
    MOUNT_DOCKER_FOLDER=/media/docker
    if [ ! -d "${MOUNT_DOCKER_FOLDER}" ]; then
        mkdir -pv ${MOUNT_DOCKER_FOLDER}
        chown -R ${CURRENT_USER_NAME}:${CURRENT_USER_GROUP} ${MOUNT_DOCKER_FOLDER}
    fi
    TMOE_LINUX_DOCKER_SHELL_FILE="${MOUNT_DOCKER_FOLDER}/.tmoe-linux-docker.sh"
    #if [ ! -e "${TMOE_LINUX_DOCKER_SHELL_FILE}" ]; then
    #aria2c --console-log-level=warn --no-conf --allow-overwrite=true -d ${MOUNT_DOCKER_FOLDER} -o ".tmoe-linux-docker.sh" https://raw.githubusercontent.com/2moe/tmoe-linux/master/debian.sh
    cp ${TMOE_GIT_DIR}/tools/virtualization/docker/configure ${TMOE_LINUX_DOCKER_SHELL_FILE}
    sed -i 's@###tmoe_locale_gen@tmoe_locale_gen@g' ${TMOE_LINUX_DOCKER_SHELL_FILE}
    sed -i 's@###tuna_mirror@tuna_mirror@g' ${TMOE_LINUX_DOCKER_SHELL_FILE}
    #fi
}
################
run_docker_container_with_same_architecture() {
    case ${SYSTEMD_DOCKER} in
    true)
        printf "%s\n" "${BLUE}docker run -itd --name ${CONTAINER_NAME} --privileged=true --env LANG=${TMOE_LANG} --env CONTAINER_SYSTEMD=true --env TMOE_CHROOT=true --env TMOE_DOCKER=true --env TMOE_PROOT=false --restart on-failure -v ${MOUNT_DOCKER_FOLDER}:${MOUNT_DOCKER_FOLDER} ${DOCKER_NAME}:${DOCKER_TAG} /sbin/init${RESET}"
        docker run -itd --name ${CONTAINER_NAME} --privileged=true --env LANG=${TMOE_LANG} --env CONTAINER_SYSTEMD=true --env TMOE_CHROOT=true --env TMOE_DOCKER=true --env TMOE_PROOT=false --restart on-failure -v ${MOUNT_DOCKER_FOLDER}:${MOUNT_DOCKER_FOLDER} ${DOCKER_NAME}:${DOCKER_TAG} /sbin/init
        ;;
    *)
        printf "%s\n" "${BLUE}docker run -itd --name ${CONTAINER_NAME} --env LANG=${TMOE_LANG} --env TMOE_CHROOT=true --env TMOE_DOCKER=true --env TMOE_PROOT=false --restart on-failure -v ${MOUNT_DOCKER_FOLDER}:${MOUNT_DOCKER_FOLDER} ${DOCKER_NAME}:${DOCKER_TAG}${RESET}"
        docker run -itd --name ${CONTAINER_NAME} --env LANG=${TMOE_LANG} --env TMOE_CHROOT=true --env TMOE_DOCKER=true --env TMOE_PROOT=false --restart on-failure -v ${MOUNT_DOCKER_FOLDER}:${MOUNT_DOCKER_FOLDER} ${DOCKER_NAME}:${DOCKER_TAG}
        ;;
    esac
}
##########
run_special_tag_docker_container() {
    tmoe_docker_init
    case "${TMOE_QEMU_ARCH}" in
    "") run_docker_container_with_same_architecture ;;
    *)
        #QEMU_USER_STATIC_PATH_01='/usr/local/bin'
        QEMU_USER_STATIC_PATH_02='/usr/bin'
        QEMU_USER_PATH="${QEMU_USER_STATIC_PATH_02}"
        #if [ -e "${QEMU_USER_STATIC_PATH_01}/qemu-aarch64-static" ]; then
        #    QEMU_USER_PATH="${QEMU_USER_STATIC_PATH_01}"
        #else
        #    QEMU_USER_PATH="${QEMU_USER_STATIC_PATH_02}"
        #fi
        case ${SYSTEMD_DOCKER} in
        true)
            printf "%s\n" "${BLUE}docker run -itd --name ${CONTAINER_NAME} --privileged=true --env LANG=${TMOE_LANG} --env CONTAINER_SYSTEMD=true --env TMOE_CHROOT=true --env TMOE_DOCKER=true --env TMOE_PROOT=false --restart on-failure -v ${QEMU_USER_PATH}/qemu-${TMOE_QEMU_ARCH}-static:${QEMU_USER_STATIC_PATH_02}/qemu-${TMOE_QEMU_ARCH}-static -v ${MOUNT_DOCKER_FOLDER}:${MOUNT_DOCKER_FOLDER} ${DOCKER_NAME}:${DOCKER_TAG} /sbin/init${RESET}"
            docker run -itd --name ${CONTAINER_NAME} --privileged=true --env LANG=${TMOE_LANG} --env CONTAINER_SYSTEMD=true --env TMOE_CHROOT=true --env TMOE_DOCKER=true --env TMOE_PROOT=false --restart on-failure -v ${QEMU_USER_PATH}/qemu-${TMOE_QEMU_ARCH}-static:${QEMU_USER_STATIC_PATH_02}/qemu-${TMOE_QEMU_ARCH}-static -v ${MOUNT_DOCKER_FOLDER}:${MOUNT_DOCKER_FOLDER} ${DOCKER_NAME}:${DOCKER_TAG} /sbin/init
            ;;
        *)
            printf "%s\n" "${BLUE}docker run -itd --name ${CONTAINER_NAME} --env LANG=${TMOE_LANG} --env TMOE_CHROOT=true --env TMOE_DOCKER=true --env TMOE_PROOT=false --restart on-failure -v ${QEMU_USER_PATH}/qemu-${TMOE_QEMU_ARCH}-static:${QEMU_USER_STATIC_PATH_02}/qemu-${TMOE_QEMU_ARCH}-static -v ${MOUNT_DOCKER_FOLDER}:${MOUNT_DOCKER_FOLDER} ${DOCKER_NAME}:${DOCKER_TAG}${RESET}"
            docker run -itd --name ${CONTAINER_NAME} --env LANG=${TMOE_LANG} --env TMOE_CHROOT=true --env TMOE_DOCKER=true --env TMOE_PROOT=false --restart on-failure -v ${QEMU_USER_PATH}/qemu-${TMOE_QEMU_ARCH}-static:${QEMU_USER_STATIC_PATH_02}/qemu-${TMOE_QEMU_ARCH}-static -v ${MOUNT_DOCKER_FOLDER}:${MOUNT_DOCKER_FOLDER} ${DOCKER_NAME}:${DOCKER_TAG}
            ;;
        esac
        ;;
    esac

    printf "%s\n" "已将宿主机的${YELLOW}${MOUNT_DOCKER_FOLDER}${RESET}目录${RED}挂载至${RESET}容器内的${BLUE}${MOUNT_DOCKER_FOLDER}${RESET}"
    printf "%s\n" "You can type ${GREEN}sudo docker exec -it ${CONTAINER_NAME} sh${RESET} to connect ${CONTAINER_NAME} container."
    printf "%s\n" "您可以输${GREEN}docker attach ${CONTAINER_NAME}${RESET}来连接${CONTAINER_NAME}容器"
    printf "%s\n" "Do you want to start and configure this container?"
    printf "%s\n" "您是否想要启动并配置本容器？"
    do_you_want_to_continue
    docker start ${CONTAINER_NAME}
    docker exec -it ${CONTAINER_NAME} /bin/sh ${TMOE_LINUX_DOCKER_SHELL_FILE}
}
##############
only_delete_docker_container() {
    service docker start 2>/dev/null || systemctl start docker
    cat <<-EOF
		${RED}docker stop ${CONTAINER_NAME}
		docker rm ${CONTAINER_NAME}${RESET}
	EOF
    do_you_want_to_continue
    docker stop ${CONTAINER_NAME} 2>/dev/null
    docker rm ${CONTAINER_NAME} 2>/dev/null
}
##########
delete_docker_container_and_image() {
    cat <<-EOF
		${RED}docker rmi ${DOCKER_NAME}:${DOCKER_TAG}
		docker rmi ${DOCKER_NAME}:${DOCKER_TAG_02}${RESET}
	EOF
    only_delete_docker_container
    #docker rm ${CONTAINER_NAME} 2>/dev/null
    docker rmi ${DOCKER_NAME}:${DOCKER_TAG} 2>/dev/null
    if [ ! -z "${DOCKER_TAG_02}" ]; then
        docker rmi ${DOCKER_NAME}:${DOCKER_TAG_02} 2>/dev/null
    fi
    docker rmi ${DOCKER_NAME} 2>/dev/null
    if [ ! -z "${DOCKER_NAME_02}" ]; then
        docker rmi ${DOCKER_NAME_02}:${DOCKER_TAG} 2>/dev/null
        docker rmi ${DOCKER_NAME_02}:${DOCKER_TAG_02} 2>/dev/null
        docker rmi ${DOCKER_NAME_02} 2>/dev/null
    fi
}
##################
reset_docker_container() {
    delete_docker_container_and_image
    printf "%s\n" "${BLUE}docker pull ${DOCKER_NAME}:${DOCKER_TAG}${RESET}"
    docker pull ${DOCKER_NAME}:${DOCKER_TAG}
    run_special_tag_docker_container
}
###############
tmoe_docker_readme() {
    cat <<-ENDOFDOCKER
	${GREEN}service docker start || systemctl start docker${RESET}	${BLUE}启动docker${RESET}
	${GREEN}systemctl enable docker${RESET}	${BLUE}将docker设定为开机自启${RESET}
	---------------------------------
    ${GREEN}docker ps${RESET} 	${BLUE}列出当前正在运行的容器${RESET}
    ${GREEN}docker ps -a${RESET} 	${BLUE}列出所有容器${RESET}
    ${GREEN}docker start ${CONTAINER_NAME}${RESET}	${BLUE}启动${CONTAINER_NAME}容器${RESET}
    ${GREEN}docker stop ${CONTAINER_NAME}${RESET} 	${BLUE}停止${CONTAINER_NAME}容器${RESET}
    ${GREEN}docker attach ${CONTAINER_NAME}${RESET} 	${BLUE}连接${CONTAINER_NAME}容器${RESET}
    ${GREEN}docker exec -it ${CONTAINER_NAME} /bin/bash${RESET} 	${BLUE}对${CONTAINER_NAME}容器执行/bin/bash${RESET}
	${GREEN}docker exec -it ${CONTAINER_NAME} /bin/sh${RESET} 	${BLUE}对${CONTAINER_NAME}容器执行/bin/sh${RESET}
ENDOFDOCKER
}
#############
custom_docker_container_tag() {
    if [ "$(printf '%s\n' "${DOCKER_NAME}" | grep '/')" ]; then
        #https://hub.docker.com/r/kalilinux/kali-rolling/tags
        DOCKER_URL="https://hub.docker.com/r/${DOCKER_NAME}/tags"
    else
        DOCKER_URL="https://hub.docker.com/_/${DOCKER_NAME}?tab=tags"
    fi
    TARGET=$(whiptail --inputbox "Please type the container tag,\nyou may be able to get more info via \n${DOCKER_URL}" 0 50 --title "DOCKER TAG" 3>&1 1>&2 2>&3)
    if [ "$?" != "0" ]; then
        ${RETURN_TO_WHERE}
    elif [ -z "${TARGET}" ]; then
        printf "%s\n" "请输入有效的值"
        printf "%s\n" "Please enter a valid value"
    else
        DOCKER_TAG=${TARGET}
        run_special_tag_docker_container
    fi
}
##########
docker_attch_container() {
    if [ ! "$(pgrep docker)" ]; then
        service docker start 2>/dev/null || systemctl start docker
    fi
    if [ "$(docker ps -a | grep ${CONTAINER_NAME})" ]; then
        docker start ${CONTAINER_NAME}
        docker exec -it ${CONTAINER_NAME} /bin/bash || docker attach ${CONTAINER_NAME}
    else
        printf "%s\n" "The ${CONTAINER_NAME} container was not found."
        printf "%s\n" "Do you want to pull ${DOCKER_NAME}?"
        printf "%s\n" "因未找到${CONTAINER_NAME}容器，故容器连接失败，请问您是否需要拉取${DOCKER_NAME}镜像并新建容器？"
        do_you_want_to_continue
        run_special_tag_docker_container
    fi

}
############
tmoe_docker_management_menu_01() {
    RETURN_TO_WHERE='tmoe_docker_management_menu_01'
    DOCKER_TAG=${DOCKER_TAG_01}
    VIRTUAL_TECH=$(
        whiptail --title "${DOCKER_NAME} CONTAINER(docker容器)" --menu "Which container do you want to run?" 0 0 0 \
            "1" "${DOCKER_TAG_01}" \
            "2" "${DOCKER_TAG_02}" \
            "3" "custom tag(运行自定义标签的容器)" \
            "4" "docker attach ${CONTAINER_NAME}(连接容器)" \
            "5" "readme of ${CONTAINER_NAME} 说明" \
            "6" "reset(重置容器数据并重拉${DOCKER_TAG}镜像)" \
            "7" "delete(删除${CONTAINER_NAME}容器)" \
            "0" "🌚 Return to previous menu 返回上级菜单" \
            3>&1 1>&2 2>&3
    )
    #############
    case ${VIRTUAL_TECH} in
    0 | "") choose_gnu_linux_docker_images ;;
    1)
        DOCKER_TAG=${DOCKER_TAG_01}
        run_special_tag_docker_container
        ;;
    2)
        DOCKER_TAG=${DOCKER_TAG_02}
        run_special_tag_docker_container
        ;;
    3) custom_docker_container_tag ;;
    4) docker_attch_container ;;
    5) tmoe_docker_readme ;;
    6) reset_docker_container ;;
    7) delete_docker_container ;;
    esac
    ###############
    press_enter_to_return
    tmoe_docker_management_menu_01
}
###########
delete_docker_container() {
    if (whiptail --title "Delete container" --yes-button 'container' --no-button 'container+image' --yesno "What do you want to delete?\n您是想要删除容器,还是删除容器+镜像？" 0 50); then
        only_delete_docker_container
    else
        delete_docker_container_and_image
    fi
}
############
tmoe_docker_management_menu_02() {
    RETURN_TO_WHERE='tmoe_docker_management_menu_02'
    DOCKER_TAG=${DOCKER_TAG_01}
    VIRTUAL_TECH=$(
        whiptail --title "${DOCKER_NAME} CONTAINER(docker容器)" --menu "Which container do you want to run?" 0 0 0 \
            "1" "${DOCKER_NAME}" \
            "2" "${DOCKER_NAME_02}" \
            "3" "custom tag(运行自定义标签的容器)" \
            "4" "docker attach ${CONTAINER_NAME}(连接容器)" \
            "5" "readme of ${CONTAINER_NAME} 说明" \
            "6" "reset(重置容器数据并重拉${DOCKER_NAME}:${DOCKER_TAG_01}镜像)" \
            "7" "delete(删除${CONTAINER_NAME}容器)" \
            "0" "🌚 Return to previous menu 返回上级菜单" \
            3>&1 1>&2 2>&3
    )
    #############
    case ${VIRTUAL_TECH} in
    0 | "") choose_gnu_linux_docker_images ;;
    1)
        DOCKER_NAME="${DOCKER_NAME}"
        run_special_tag_docker_container
        ;;
    2)
        DOCKER_NAME="${DOCKER_NAME_02}"
        run_special_tag_docker_container
        ;;
    3) custom_docker_container_tag ;;
    4) docker_attch_container ;;
    5) tmoe_docker_readme ;;
    6) reset_docker_container ;;
    7) delete_docker_container ;;
    esac
    ###############
    press_enter_to_return
    tmoe_docker_management_menu_02
}
###########
tmoe_docker_management_menu_03() {
    RETURN_TO_WHERE='tmoe_docker_management_menu_03'
    DOCKER_TAG=${DOCKER_TAG_01}
    VIRTUAL_TECH=$(
        whiptail --title "${DOCKER_NAME} CONTAINER(docker容器)" --menu "Which container do you want to run?" 0 0 0 \
            "1" "${DOCKER_TAG_01}" \
            "2" "custom tag(运行自定义标签的容器)" \
            "3" "readme of ${CONTAINER_NAME} 说明" \
            "4" "docker attach ${CONTAINER_NAME}(连接容器)" \
            "5" "reset(重置容器数据并重拉${DOCKER_TAG_01}镜像)" \
            "6" "delete(删除${CONTAINER_NAME}容器)" \
            "0" "🌚 Return to previous menu 返回上级菜单" \
            3>&1 1>&2 2>&3
    )
    #############
    case ${VIRTUAL_TECH} in
    0 | "") choose_gnu_linux_docker_images ;;
    1) run_special_tag_docker_container ;;
    2) custom_docker_container_tag ;;
    3) tmoe_docker_readme ;;
    4) docker_attch_container ;;
    5) reset_docker_container ;;
    6) delete_docker_container ;;
    esac
    ###############
    press_enter_to_return
    tmoe_docker_management_menu_03
}
###########
not_adapted_across_architecture() {
    if [ ! -z "${TMOE_QEMU_ARCH}" ]; then
        #TMOE_QEMU_ARCH=''
        #此处不要清除变量
        printf "%s\n" "${RED}WARNING！${RESET}本脚本未适配${CONTAINER_NAME}容器的跨架构运行。"
        press_enter_to_continue
    fi
}
###############
only_support_amd64_container() {
    case ${TMOE_QEMU_ARCH} in
    x86_64) ;;
    "")
        case ${TRUE_ARCH_TYPE} in
        amd64) ;;
        *) arch_does_not_support ;;
        esac
        ;;
    *) arch_does_not_support ;;
    esac
}
#############
only_support_amd64_and_arm64v8_container() {
    case ${TMOE_QEMU_ARCH} in
    x86_64 | aarch64) ;;
    "")
        case ${TRUE_ARCH_TYPE} in
        amd64 | arm64) ;;
        *) arch_does_not_support ;;
        esac
        ;;
    *) arch_does_not_support ;;
    esac
}
#############
gentoo_stage3_amd64() {
    DOCKER_NAME='gentoo/stage3-amd64'
    DOCKER_NAME_02='gentoo/stage3-amd64-hardened-nomultilib'
}
########
gentoo_stage3_i386() {
    DOCKER_NAME='gentoo/stage3-x86'
    DOCKER_NAME_02='gentoo/stage3-x86-hardened'
}
########
gentoo_stage3_armhf() {
    DOCKER_NAME='paralin/gentoo-stage3-armv7a'
    DOCKER_NAME_02='applehq/gentoo-stage4'
}
########
arch_docker_amd64() {
    DOCKER_NAME='archlinux'
    DOCKER_MANAGEMENT_MENU='03'
}
##########
arch_docker_arm64() {
    DOCKER_NAME='lopsided/archlinux'
    DOCKER_NAME_02='agners/archlinuxarm'
    DOCKER_MANAGEMENT_MENU='02'
}
##########
openwrt_docker_amd64() {
    DOCKER_NAME='openwrtorg/rootfs'
    DOCKER_NAME_02='katta/openwrt-rootfs'
    DOCKER_MANAGEMENT_MENU='02'
}
###########
openwrt_docker_arm64() {
    DOCKER_NAME='buddyfly/openwrt-aarch64'
    DOCKER_NAME_02='unifreq/openwrt-aarch64'
    DOCKER_MANAGEMENT_MENU='02'
}
############
kali_docker_amd64() {
    DOCKER_NAME='kalilinux/kali-rolling'
    DOCKER_NAME_02='kalilinux/kali'
}
kali_docker_armhf() {
    DOCKER_NAME='rbartoli/kali-linux-arm'
    DOCKER_NAME_02='williamlegourd/kali-gui'
}
kali_docker_arm64() {
    DOCKER_NAME='donaldrich/kali-linux'
    DOCKER_NAME_02='heywoodlh/kali-linux'
}
###############
sbin_init_systemd_docker_list() {
    check_docker_installation
    RETURN_TO_WHERE='sbin_init_systemd_docker_list'
    DOCKER_TAG_01='latest'
    CONTAINER_NAME=''
    DOCKER_MANAGEMENT_MENU='01'
    SELECTED_GNU_LINUX=$(whiptail --title "DOCKER IMAGES" --menu "Which distribution image do you want to pull? \n您想要拉取哪个GNU/Linux发行版的镜像?" 0 50 0 \
        "0" "Return to previous menu 返回上级菜单" \
        "1" "👒 fedora:红帽社区版,新技术试验场" \
        "2" "centos(基于红帽的社区企业操作系统)" \
        3>&1 1>&2 2>&3)
    #############
    case ${SELECTED_GNU_LINUX} in
    0 | "") tmoe_docker_menu ;;
    1)
        DOCKER_TAG_02='rawhide'
        DOCKER_NAME='fedora'
        ;;
    2)
        DOCKER_TAG_01='latest'
        DOCKER_TAG_02='7'
        DOCKER_NAME='centos'
        CONTAINER_NAME='cent-systemd'
        ;;
    esac
    ###############
    if [ -z "${CONTAINER_NAME}" ]; then
        CONTAINER_NAME=${DOCKER_NAME}-systemd
    fi
    case "${TMOE_QEMU_ARCH}" in
    "") ;;
    *)
        case ${DOCKER_MANAGEMENT_MENU} in
        01 | 03)
            DOCKER_NAME="${NEW_TMOE_ARCH}/${DOCKER_NAME}"
            CONTAINER_NAME="${CONTAINER_NAME}_${CONTAINER_EXT_NAME}"
            ;;
        02)
            CONTAINER_NAME="${CONTAINER_NAME}_${CONTAINER_EXT_NAME}"
            ;;
        esac
        ;;
    esac
    #########
    case ${DOCKER_MANAGEMENT_MENU} in
    01) tmoe_docker_management_menu_01 ;;
    02) tmoe_docker_management_menu_02 ;;
    03) tmoe_docker_management_menu_03 ;;
    esac
    ###########
    press_enter_to_return
    sbin_init_systemd_docker_list
}
#############
choose_gnu_linux_docker_images() {
    check_docker_installation
    RETURN_TO_WHERE='choose_gnu_linux_docker_images'
    DOCKER_TAG_01='latest'
    CONTAINER_NAME=''
    DOCKER_MANAGEMENT_MENU='01'
    SELECTED_GNU_LINUX=$(whiptail --title "DOCKER IMAGES" --menu "Which distribution image do you want to pull? \n您想要拉取哪个GNU/Linux发行版的镜像?" 0 50 0 \
        "0" "Return to previous menu 返回上级菜单" \
        "1" "🏔️ alpine:非glibc的精简系统" \
        "2" "🍥 Debian:最早的发行版之一" \
        "3" "🍛 Ubuntu:我的存在是因為大家的存在" \
        "4" "🐉 Kali Rolling:设计用于数字取证和渗透测试" \
        "5" "arch:系统设计以KISS为总体指导原则" \
        "6" "👒 fedora:红帽社区版,新技术试验场" \
        "7" "centos(基于红帽的社区企业操作系统)" \
        "8" "opensuse tumbleweed(小蜥蜴风滚草)" \
        "9" "gentoo(追求极限配置和极高自由,stage3-amd64)" \
        "10" "clearlinux(intel发行的系统)" \
        "11" "Void(基于xbps包管理器的独立发行版)" \
        "12" "oracle(甲骨文基于红帽发行的系统)" \
        "13" "amazon(亚马逊云服务发行版)" \
        "14" "crux(lightweight轻量化)" \
        "15" "openwrt(常见于路由器)" \
        "16" "alt(起源于俄罗斯的发行版)" \
        "17" "photon(VMware专为ESXi定制的容器系统)" \
        3>&1 1>&2 2>&3)
    #############
    case ${SELECTED_GNU_LINUX} in
    0 | "") tmoe_docker_menu ;;
    1)
        DOCKER_TAG_02='edge'
        DOCKER_NAME='alpine'
        ;;
    2)
        DOCKER_TAG_01='unstable'
        DOCKER_TAG_02='stable'
        DOCKER_NAME='debian'
        ;;
    3)
        DOCKER_TAG_02='devel'
        DOCKER_NAME='ubuntu'
        ;;
    4)
        CONTAINER_NAME='kali'
        case ${TMOE_QEMU_ARCH} in
        x86_64) kali_docker_amd64 ;;
        arm) kali_docker_armhf ;;
        aarch64 | i386) kali_docker_arm64 ;;
        "")
            case ${TRUE_ARCH_TYPE} in
            amd64) kali_docker_amd64 ;;
            armhf) kali_docker_armhf ;;
            arm64 | i386) kali_docker_arm64 ;;
            *) arch_does_not_support ;;
            esac
            ;;
        *) arch_does_not_support ;;
        esac
        DOCKER_MANAGEMENT_MENU='02'
        ;;
    5)
        CONTAINER_NAME='arch'
        case ${TMOE_QEMU_ARCH} in
        x86_64) arch_docker_amd64 ;;
        arm | aarch64) arch_docker_arm64 ;;
        "")
            case ${TRUE_ARCH_TYPE} in
            amd64) arch_docker_amd64 ;;
            arm*) arch_docker_arm64 ;;
            *) arch_does_not_support ;;
            esac
            ;;
        *) arch_does_not_support ;;
        esac
        ;;
    6)
        DOCKER_TAG_02='rawhide'
        DOCKER_NAME='fedora'
        ;;
    7)
        DOCKER_TAG_01='latest'
        DOCKER_TAG_02='7'
        DOCKER_NAME='centos'
        CONTAINER_NAME='cent'
        ;;
    8)
        CONTAINER_NAME='suse'
        not_adapted_across_architecture
        DOCKER_NAME='opensuse/tumbleweed'
        DOCKER_NAME_02='opensuse/leap'
        DOCKER_MANAGEMENT_MENU='02'
        ;;
    9)
        CONTAINER_NAME='gentoo'
        case ${TMOE_QEMU_ARCH} in
        x86_64) gentoo_stage3_amd64 ;;
        i386) gentoo_stage3_i386 ;;
        arm | aarch64) gentoo_stage3_armhf ;;
        "")
            case ${TRUE_ARCH_TYPE} in
            amd64) gentoo_stage3_amd64 ;;
            i386) gentoo_stage3_i386 ;;
            arm*) gentoo_stage3_armhf ;;
            *) arch_does_not_support ;;
            esac
            ;;
        *) arch_does_not_support ;;
        esac
        DOCKER_MANAGEMENT_MENU='02'
        ;;
    10)
        only_support_amd64_container
        CONTAINER_NAME='clear'
        DOCKER_TAG_01='latest'
        DOCKER_TAG_02='base'
        DOCKER_NAME='clearlinux'
        ;;
    11)
        DOCKER_NAME='voidlinux/voidlinux'
        DOCKER_NAME_02='voidlinux/voidlinux-musl'
        CONTAINER_NAME='void'
        DOCKER_MANAGEMENT_MENU='02'
        ;;
    12)
        only_support_amd64_container
        DOCKER_TAG_02='7'
        DOCKER_NAME='oraclelinux'
        CONTAINER_NAME='oracle'
        ;;
    13)
        only_support_amd64_and_arm64v8_container
        DOCKER_TAG_02='with-sources'
        DOCKER_NAME='amazonlinux'
        CONTAINER_NAME='amazon'
        ;;
    14)
        only_support_amd64_and_arm64v8_container
        DOCKER_TAG_02='3.4'
        DOCKER_NAME='crux'
        ;;
    15)
        CONTAINER_NAME='openwrt'
        ########
        case ${TMOE_QEMU_ARCH} in
        x86_64) openwrt_docker_amd64 ;;
        aarch64) openwrt_docker_arm64 ;;
        "")
            case ${TRUE_ARCH_TYPE} in
            amd64) openwrt_docker_amd64 ;;
            arm64) openwrt_docker_arm64 ;;
            *) arch_does_not_support ;;
            esac
            ;;
        *) arch_does_not_support ;;
        esac
        ;;
    16)
        DOCKER_TAG_02='sisyphus'
        DOCKER_NAME='alt'
        ;;
    17)
        only_support_amd64_and_arm64v8_container
        DOCKER_TAG_02='2.0'
        DOCKER_NAME='photon'
        ;;
    esac
    ###############
    if [ -z "${CONTAINER_NAME}" ]; then
        CONTAINER_NAME=${DOCKER_NAME}
    fi
    case "${TMOE_QEMU_ARCH}" in
    "") ;;
    *)
        case ${DOCKER_MANAGEMENT_MENU} in
        01 | 03)
            DOCKER_NAME="${NEW_TMOE_ARCH}/${DOCKER_NAME}"
            CONTAINER_NAME="${CONTAINER_NAME}_${CONTAINER_EXT_NAME}"
            ;;
        02)
            CONTAINER_NAME="${CONTAINER_NAME}_${CONTAINER_EXT_NAME}"
            ;;
        esac
        ;;
    esac
    #########
    case ${DOCKER_MANAGEMENT_MENU} in
    01) tmoe_docker_management_menu_01 ;;
    02) tmoe_docker_management_menu_02 ;;
    03) tmoe_docker_management_menu_03 ;;
    esac
    ###########
    press_enter_to_return
    choose_gnu_linux_docker_images
}
#############
install_docker_ce_or_io() {
    case "${TMOE_PROOT}" in
    true)
        printf "%s\n" "${RED}WARNING！${RESET}检测到您当前处于${GREEN}proot容器${RESET}环境下！"
        printf "%s\n" "若您处于容器环境下,且宿主机为${BOLD}Android${RESET}系统，则请在安装前${BLUE}确保${RESET}您的Linux内核支持docker"
        printf "%s\n" "否则请通过qemu-system来运行GNU/Linux虚拟机，再安装docker。"
        printf "%s\n" "If your host is android, it is recommended that you use the qemu-system virtual machine to run docker."
        do_you_want_to_continue
        ;;
    false) printf "%s\n" "检测到您当前处于chroot容器环境下" ;;
    esac
    if (whiptail --title "DOCKER本体" --yes-button 'docker-ce' --no-button 'docker.io' --yesno "Please make sure your linux kernel supports docker.\n安装前请先确保您的linux内核支持docker。为避免冲突,请只选择其中一个。" 0 50); then
        install_docker_ce
    else
        install_docker_io
    fi
    docker version
}
##############
add_current_user_to_docker_group() {
    printf "%s\n" "Do you want to add ${CURRENT_USER_NAME} to docker group?"
    printf "%s\n" "${YELLOW}gpasswd -a ${CURRENT_USER_NAME} docker${RESE}"
    do_you_want_to_continue
    if [ ! "$(groups | grep docker)" ]; then
        groupadd docker
    fi
    gpasswd -a ${CURRENT_USER_NAME} docker
    printf "%s\n" "您可以手动执行${GREEN}newgrp docker${RESET}来刷新docker用户组"
    printf "%s\n" "If you want to remove it,then type ${RED}gpasswd -d ${CURRENT_USER_NAME} docker${RESET}"
    printf "%s\n" "若您需要将当前用户移出docker用户组，则请输${RED}gpasswd -d ${CURRENT_USER_NAME} docker${RESET}"
}
##########
docker_163_mirror() {
    if [ ! -d /etc/docker ]; then
        mkdir -pv /etc/docker
    fi
    cd /etc/docker
    if [ ! -e daemon.json ]; then
        printf "\n" >daemon.json
    fi
    if ! grep -q 'registry-mirrors' "daemon.json"; then
        cat >>daemon.json <<-'EOF'
		
			{
			"registry-mirrors": [
			"https://hub-mirror.c.163.com/"
			]
			}
		EOF
    else
        cat <<-'EOF'
			检测到您已经设定了registry-mirrors,请手动修改daemon.json为以下配置。
			{
			"registry-mirrors": [
			"https://hub-mirror.c.163.com/"
			]
			}
		EOF
    fi
}
##########
docker_mirror_source() {
    RETURN_TO_WHERE='docker_mirror_source'
    VIRTUAL_TECH=$(
        whiptail --title "DOCKER MIRROR" --menu "您想要修改哪些docker配置？" 0 0 0 \
            "1" "163镜像" \
            "2" "edit daemon.json" \
            "3" "edit software source软件本体源" \
            "0" "🌚 Return to previous menu 返回上级菜单" \
            3>&1 1>&2 2>&3
    )
    #############
    case ${VIRTUAL_TECH} in
    0 | "") tmoe_docker_menu ;;
    1) docker_163_mirror ;;
    2) nano /etc/docker/daemon.json ;;
    3)
        non_debian_function
        nano /etc/apt/sources.list.d/docker.list
        ;;
    esac
    ###############
    press_enter_to_return
    docker_mirror_source
}
##########
tmoe_docker_menu() {
    RETURN_TO_WHERE='tmoe_docker_menu'
    # RETURN_TO_MENU='tmoe_docker_menu'
    SYSTEMD_DOCKER=false
    TMOE_QEMU_ARCH=""
    VIRTUAL_TECH=$(
        whiptail --title "DOCKER容器" --menu "您想要对docker小可爱做什么?" 0 0 0 \
            "1" "🌁 cross-architecture(跨CPU架构运行docker容器)" \
            "2" "🥛 systemd-docker(支持systemctl的docker容器)" \
            "3" "🍭 pull distro images(拉取alpine,debian和ubuntu镜像)" \
            "4" "🌉 portainer(web端图形化docker容器管理)" \
            "5" "export container 导出容器(备份)" \
            "6" "import image 导入镜像(恢复)" \
            "7" "🍥 mirror source镜像源" \
            "8" "🐋 install docker-ce(安装docker社区版引擎)" \
            "9" "add ${CURRENT_USER_NAME} to docker group(添加当前用户至docker用户组)" \
            "0" "🌚 Return to previous menu 返回上级菜单" \
            3>&1 1>&2 2>&3
    )
    #############
    case ${VIRTUAL_TECH} in
    0 | "") install_container_and_virtual_machine ;;
    1) run_docker_across_architectures ;;
    2) systemd_docker_env ;;
    3) choose_gnu_linux_docker_images ;;
    4) install_docker_portainer ;;
    5) export_docker_image_menu ;;
    6) import_docker_image_menu ;;
    7) docker_mirror_source ;;
    8) install_docker_ce_or_io ;;
    9) add_current_user_to_docker_group ;;
    esac
    ###############
    press_enter_to_return
    tmoe_docker_menu
}
############
case_tar_file_and_extract() {
    cd ${FILE_PATH}
    case "${SELECTION:0-6:6}" in
    tar.xz)
        xz -d -k -v "${TMOE_FILE_ABSOLUTE_PATH}"
        TMOE_TAR_ITEM="${SELECTION%???}"
        chmod -v a+rw ${TMOE_TAR_ITEM}
        docker_import_command
        # rm -fv ${TMOE_TAR_ITEM}
        ;;
    tar.gz)
        gzip -d -k -v "${TMOE_FILE_ABSOLUTE_PATH}"
        TMOE_TAR_ITEM="${SELECTION%???}"
        chmod -v a+rw ${TMOE_TAR_ITEM}
        docker_import_command
        # rm -fv ${TMOE_TAR_ITEM}
        ;;
    ar.zst)
        zstd -dv "${TMOE_FILE_ABSOLUTE_PATH}"
        TMOE_TAR_ITEM="${SELECTION%????}"
        chmod -v a+rw ${TMOE_TAR_ITEM}
        docker_import_command
        # rm -fv ${TMOE_TAR_ITEM}
        ;;
    *)
        TMOE_TAR_ITEM="${TMOE_FILE_ABSOLUTE_PATH}"
        docker_import_command
        ;;
    esac
}
###############
docker_import_command() {
    ls -lah "${TMOE_TAR_ITEM}"
    DOCKER_NAME=$(printf "%s\n" "${SELECTION}" | sed -e 's@.tar.*@@' -e 's@_bak-.*@@' -e 's@+@-@')
    DOCKER_TAG=$(date +%Y-%m-%d_%H-%M)
    printf "%s\n" "${GREEN}docker ${PURPLE}import - ${BLUE}${DOCKER_NAME}:${YELLOW}${DOCKER_TAG} ${RED}<${BLUE}${TMOE_TAR_ITEM}${RESET}"
    do_you_want_to_continue
    docker import - ${DOCKER_NAME}:${DOCKER_TAG} <${TMOE_TAR_ITEM}
}
###############
import_docker_image_menu() {
    RETURN_TO_WHERE='tmoe_docker_menu'
    FILE_EXT_01='tar'
    FILE_EXT_02='tar.*'
    #where_is_tmoe_file_dir
    for i in "${HOME}/sd/Download/backup/rootfs" "/media/sd/Download/backup/rootfs" "${HOME}/sd" "${HOME}"; do
        if [[ -d ${i} ]]; then
            START_DIR="${i}"
            break
        fi
    done
    IMPORTANT_TIPS='您可以选择tmoe每周构建版镜像,也可以选择本地tar文件'
    tmoe_file_manager
    if [ -z ${SELECTION} ]; then
        printf "%s\n" "没有指定${YELLOW}有效${RESET}的${BLUE}文件${GREEN}，请${GREEN}重新${RESET}选择"
    else
        printf "%s\n" "您选择的文件为${TMOE_FILE_ABSOLUTE_PATH}"
        stat "${TMOE_FILE_ABSOLUTE_PATH}"
        ls -lah "${TMOE_FILE_ABSOLUTE_PATH}"
        do_you_want_to_continue
        case_tar_file_and_extract
        printf "%s\n" "${GREEN}docker ${BLUE}images${RESET}"
        docker images
        please_type_the_container_name
        printf "%s\n" "Do you want to run this container now?"
        if [[ -d /media/docker ]]; then
            MOUNT_DOCKER_FOLDER=/media/docker
            printf "%s\n" "${BLUE}docker run -itd --name ${CONTAINER_NAME} --env LANG=${TMOE_LANG} --restart on-failure -v ${MOUNT_DOCKER_FOLDER}:${MOUNT_DOCKER_FOLDER} ${DOCKER_NAME}:${DOCKER_TAG} sh${RESET}"
        else
            printf "%s\n" "${BLUE}docker run -itd --name ${CONTAINER_NAME} --env LANG=${TMOE_LANG} --restart on-failure ${DOCKER_NAME}:${DOCKER_TAG} sh${RESET}"
        fi
        do_you_want_to_continue

        if [[ -d /media/docker ]]; then
            docker run -itd --name ${CONTAINER_NAME} --env LANG=${TMOE_LANG} --restart on-failure -v ${MOUNT_DOCKER_FOLDER}:${MOUNT_DOCKER_FOLDER} ${DOCKER_NAME}:${DOCKER_TAG} sh
        else
            docker run -itd --name ${CONTAINER_NAME} --env LANG=${TMOE_LANG} --restart on-failure ${DOCKER_NAME}:${DOCKER_TAG} sh
        fi
        printf "%s\n" "You can run ${GREEN}docker exec ${BLUE}-it ${YELLOW}${CONTAINER_NAME} ${RED}sh${RESET} to attach it."
    fi
}
please_type_the_container_name() {
    CONTAINER_NAME=$(whiptail --inputbox "Please type the container name\n请输入容器文件名称,若留空则将自动命名为${DOCKER_NAME}" 0 50 --title "CONTAINER NAME" 3>&1 1>&2 2>&3)
    if [ -z "${CONTAINER_NAME}" ]; then
        CONTAINER_NAME="${DOCKER_NAME}"
    fi
}
export_docker_image_menu() {
    RETURN_TO_WHERE='export_docker_image_menu'
    cd /tmp/
    docker ps -a | awk '{print $NF}' | sed '1d' >.tmoe-linux_cache.01
    docker ps -a | awk '{print $2}' | sed '1d' >.tmoe-linux_cache.02
    TMOE_CONTAINER_LIST=$(paste -d ' ' .tmoe-linux_cache.01 .tmoe-linux_cache.02 | sed ":a;N;s/\n/ /g;ta")
    rm -f .tmoe-linux_cache.0*
    DOCKER_NAME=$(whiptail --title "CONTAINER LIST" --menu \
        "Which container do you want to backup?" 0 0 0 \
        ${TMOE_CONTAINER_LIST} \
        "0" "🌚 Return to previous menu 返回上级菜单" \
        3>&1 1>&2 2>&3)
    case ${DOCKER_NAME} in
    0 | "") tmoe_docker_menu ;;
    esac
    type_the_file_path
    DOCKER_BAK_FILE="${TARGET}/${DOCKER_NAME}_bak-$(date +%Y-%m-%d_%H-%M).tar"
    printf "%s\n" "${GREEN}docker export ${BLUE}${DOCKER_NAME} ${PURPLE}> ${YELLOW}${DOCKER_BAK_FILE}${RESET}"
    do_you_want_to_continue
    docker export ${DOCKER_NAME} >${DOCKER_BAK_FILE}
    if [[ ${HOME} != /root ]]; then
        chown -v ${CURRENT_USER_NAME}:${CURRENT_USER_GROUP} ${DOCKER_BAK_FILE}
        chmod -v a+rw ${DOCKER_BAK_FILE}
    fi
    stat ${DOCKER_BAK_FILE}
    ls -lah ${DOCKER_BAK_FILE}
}
##########
type_the_file_path() {
    for i in "${HOME}/sd/Download/backup/rootfs" "/media/sd/Download/backup/rootfs" "${HOME}/sd" "${HOME}"; do
        if [[ -d ${i} ]]; then
            START_DIR="${i}"
            break
        fi
    done
    TARGET=$(whiptail --inputbox "Please type the file path\n请输入文件保存路径，若留空则输出至${START_DIR}" 0 50 --title "FILE DIR" 3>&1 1>&2 2>&3)
    if [ "${?}" != "0" ]; then
        ${RETURN_TO_WHERE}
    elif [ -z "${TARGET}" ]; then
        TARGET="${START_DIR}"
    elif [[ ! -x ${TARGET} ]]; then
        printf "%s\n" "${RED}ERROR${RESET},please retype."
        printf "%s\n" "文件路径不存在或无法被访问，请重新输入。"
        press_enter_to_return
        type_the_file_path
    fi
}
systemd_docker_env() {
    #printf "%s\n" 本功能正在开发中...
    #press_enter_to_return
    SYSTEMD_DOCKER=true
    run_docker_across_architectures
}
apt_install_qemu_user_static() {
    DEPENDENCY_01='qemu-user-static'
    DEPENDENCY_02=''
    beta_features_quick_install
    if [ ! -e "/usr/bin/qemu-aarch64-static" ]; then
        cat <<-'EOF'
        安装失败，请手动执行以下命令，或通过安装包来安装。
        docker pull multiarch/qemu-user-static:register
        docker run --rm --privileged multiarch/qemu-user-static:register
EOF
    fi
}
############
tmoe_qemu_user_static() {
    RETURN_TO_WHERE='tmoe_qemu_user_static'
    BETA_SYSTEM=$(
        whiptail --title "qemu_user_static" --menu "You can use qemu-user-static to run docker containers cross-architecture." 0 50 0 \
            "1" "chart架构支持表格" \
            "2" "install via software source(通过软件源安装)" \
            "3" "install/upgrade(通过安装包来安装/更新)" \
            "4" "remove(移除/卸载)" \
            "0" "🌚 Return to previous menu 返回上级菜单" \
            3>&1 1>&2 2>&3
    )
    ##############################
    case "${BETA_SYSTEM}" in
    0 | "") run_docker_across_architectures ;;
    1) tmoe_qemu_user_chart ;;
    2) apt_install_qemu_user_static ;;
    3) install_qemu_user_static ;;
    4) remove_qemu_user_static ;;
    esac
    ######################
    press_enter_to_return
    tmoe_qemu_user_static
}
#####################
tmoe_qemu_user_chart() {
    cat <<-'ENDofTable'
		下表中的所有系统均支持x64(amd64)和arm64
		*表示仅旧版支持
			╔═══╦════════════╦════════╦════════╦═════════╦
			║   ║Architecture║        ║        ║         ║
			║   ║----------- ║ x86    ║armhf   ║ppc64el  ║
			║   ║System      ║        ║        ║         ║
			║---║------------║--------║--------║---------║
			║ 1 ║  Debian    ║  ✓     ║    ✓   ║   ✓     ║
			║   ║            ║        ║        ║         ║
			║---║------------║--------║--------║---------║
			║   ║            ║        ║        ║         ║
			║ 2 ║  Ubuntu    ║*<=19.10║   ✓    ║   ✓     ║
			║---║------------║--------║--------║---------║
			║   ║            ║        ║        ║         ║
			║ 3 ║ Kali       ║  ✓     ║   ✓    ║    X    ║
			║---║------------║--------║--------║---------║
			║   ║            ║        ║        ║         ║
			║ 4 ║ Arch       ║  X     ║   ✓    ║   X     ║
			║---║------------║--------║--------║---------║
			║   ║            ║        ║        ║         ║
			║ 5 ║ Fedora     ║ *<=29  ║   ✓    ║  ✓      ║
			║---║------------║--------║--------║---------║
			║   ║            ║        ║        ║         ║
			║ 6 ║  Alpine    ║  ✓     ║    ✓   ║   ✓     ║
			║---║------------║--------║--------║---------║
			║   ║            ║        ║        ║         ║
			║ 7 ║ Centos     ║ *<=7   ║ *<=7   ║   ✓     ║
	ENDofTable
}
###############
install_qemu_user_static() {
    printf "%s\n" "正在检测版本信息..."
    LOCAL_QEMU_USER_FILE=''
    #if [ -e "/usr/local/bin/qemu-aarch64-static" ]; then
    #   LOCAL_QEMU_USER_FILE='/usr/local/bin/qemu-aarch64-static'
    if [ -e "/usr/bin/qemu-aarch64-static" ]; then
        LOCAL_QEMU_USER_FILE='/usr/bin/qemu-aarch64-static'
    fi
    case ${LOCAL_QEMU_USER_FILE} in
    "") LOCAL_QEMU_USER_VERSION='您尚未安装QEMU-USER-STATIC' ;;
    *) LOCAL_QEMU_USER_VERSION=$(${LOCAL_QEMU_USER_FILE} --version | head -n 1 | awk '{print $5}' | cut -d ':' -f 2 | cut -d ')' -f 1) ;;
    esac

    cat <<-'EOF'
		---------------------------
		一般来说，新版的qemu-user会引入新的功能，并带来性能上的提升。
		尽管有可能会引入一些新bug，但是也有可能修复了旧版的bug。
		We recommend that you to use the new version.
		---------------------------
	EOF
    check_qemu_user_version
    cat <<-ENDofTable
		╔═══╦══════════╦═══════════════════╦════════════════════
		║   ║          ║                   ║                    
		║   ║ software ║    ✨最新版本     ║   本地版本 🎪
		║   ║          ║  Latest version   ║  Local version     
		║---║----------║-------------------║--------------------
		║ 1 ║qemu-user ║                    ${LOCAL_QEMU_USER_VERSION} 
		║   ║ static   ║$(printf '%s\n' "${THE_LATEST_DEB_VERSION_CODE}" | sed 's@%2B@+@')

	ENDofTable
    do_you_want_to_continue
    THE_LATEST_DEB_LINK="${REPO_URL}${THE_LATEST_DEB_VERSION}"
    printf "%s\n" "${THE_LATEST_DEB_LINK}"
    #printf "%s\n" "${THE_LATEST_DEB_VERSION_CODE}" >${QEMU_USER_LOCAL_VERSION_FILE}
    download_qemu_user
    unxz_deb_file
}
##############
check_qemu_user_version() {
    REPO_URL='https://mirrors.bfsu.edu.cn/debian/pool/main/q/qemu/'
    THE_LATEST_DEB_VERSION="$(curl -L ${REPO_URL} | grep '\.deb' | grep 'qemu-user-static' | grep "${TRUE_ARCH_TYPE}" | tail -n 1 | cut -d '=' -f 3 | cut -d '"' -f 2)"
    THE_LATEST_DEB_VERSION_CODE=$(printf '%s\n' "${THE_LATEST_DEB_VERSION}" | cut -d '_' -f 2)
}
###############
unxz_deb_file() {
    if [ ! $(command -v ar) ]; then
        DEPENDENCY_01='binutils'
        DEPENDENCY_02=''
        beta_features_quick_install
    fi
    ar xv ${THE_LATEST_DEB_VERSION}
    #tar -Jxvf data.tar.xz ./usr/bin -C $PREFIX/..
    #tar -Jxvf data.tar.xz
    cd /
    tar -Jxvf ${TMPDIR}/${TEMP_FOLDER}/data.tar.xz ./usr/bin
    #cp -rf ./usr/bin /usr
    #cd ..
    rm -rv ${TMPDIR}/${TEMP_FOLDER}
    docker run --rm --privileged multiarch/qemu-user-static:register
}
########################
download_qemu_user() {
    cd ${TMPDIR}
    TEMP_FOLDER='.QEMU_USER_BIN'
    mkdir -pv ${TEMP_FOLDER}
    cd ${TEMP_FOLDER}
    aria2c --console-log-level=warn --no-conf --allow-overwrite=true -s 5 -x 5 -k 1M -o "${THE_LATEST_DEB_VERSION}" "${THE_LATEST_DEB_LINK}"
}
##############
remove_qemu_user_static() {
    ls -lah /usr/bin/qemu-*-static 2>/dev/null
    printf "%s\n" "${RED}rm -rv${RESET} ${BLUE}/usr/bin/qemu-*-static${RESET}"
    printf "%s\n" "${RED}${TMOE_REMOVAL_COMMAND}${RESET} ${BLUE}qemu-user-static${RESET}"
    do_you_want_to_continue
    rm -rv /usr/bin/qemu-*-static
    ${TMOE_REMOVAL_COMMAND} qemu-user-static
}
##############
run_docker_across_architectures() {
    check_docker_installation
    TMOE_QEMU_ARCH=""
    BETA_SYSTEM=$(
        whiptail --title "跨架构运行容器" --menu "您想要(模拟)运行哪个架构？\nWhich architecture do you want to simulate?" 0 50 0 \
            "0" "🌚 Return to previous menu 返回上级菜单" \
            "00" "qemu-user-static管理(跨架构模拟所需的基础依赖)" \
            "1" "x64/amd64(64位架构,应用于pc和服务器）" \
            "2" "arm64v8/aarch64(常见于移动平台的64位cpu架构）" \
            "3" "i386(常见于32位cpu的旧式传统pc)" \
            "4" "arm32v7/armhf(32位arm架构,支持硬浮点运算)" \
            "5" "ppc64le(PowerPC,常用于通信、工控、航天国防等领域)" \
            "6" "s390x(常见于IBM大型机)" \
            3>&1 1>&2 2>&3
    )
    ##############################
    case "${BETA_SYSTEM}" in
    0 | "") tmoe_docker_menu ;;
    00) tmoe_qemu_user_static ;;
    1)
        NEW_TMOE_ARCH='amd64'
        CONTAINER_EXT_NAME='x64'
        case ${TRUE_ARCH_TYPE} in
        amd64) ;;
        *) TMOE_QEMU_ARCH="x86_64" ;;
        esac
        ;;
    2)
        NEW_TMOE_ARCH='arm64v8'
        CONTAINER_EXT_NAME='arm64'
        case ${TRUE_ARCH_TYPE} in
        arm64) ;;
        *) TMOE_QEMU_ARCH="aarch64" ;;
        esac
        ;;
    3)
        NEW_TMOE_ARCH='i386'
        CONTAINER_EXT_NAME='x86'
        case ${TRUE_ARCH_TYPE} in
        i386) ;;
        *) TMOE_QEMU_ARCH="${NEW_TMOE_ARCH}" ;;
        esac
        ;;
    4)
        NEW_TMOE_ARCH='arm32v7'
        CONTAINER_EXT_NAME='arm'
        case ${TRUE_ARCH_TYPE} in
        armhf) ;;
        *) TMOE_QEMU_ARCH="arm" ;;
        esac
        ;;
    5)
        NEW_TMOE_ARCH='ppc64le'
        CONTAINER_EXT_NAME='ppc'
        case ${TRUE_ARCH_TYPE} in
        ppc64el) ;;
        *) TMOE_QEMU_ARCH="ppc64le" ;;
        esac
        ;;
    6)
        NEW_TMOE_ARCH='s390x'
        CONTAINER_EXT_NAME='s390'
        case ${TRUE_ARCH_TYPE} in
        s390x) ;;
        *) TMOE_QEMU_ARCH="s390x" ;;
        esac
        ;;
    esac
    ######################
    if [ ! -e "/usr/bin/qemu-x86_64-static" ]; then
        install_qemu_user_static
    fi
    case ${SYSTEMD_DOCKER} in
    true) sbin_init_systemd_docker_list ;;
    *) choose_gnu_linux_docker_images ;;
    esac
    press_enter_to_return
    run_docker_across_architectures
}
#####################
debian_add_docker_gpg() {
    if [ "${DEBIAN_DISTRO}" = 'ubuntu' ]; then
        DOCKER_RELEASE='ubuntu'
    else
        DOCKER_RELEASE='debian'
    fi
    DOCKER_TUNA_CODE_LIST=$(curl -L "https://mirrors.bfsu.edu.cn/docker-ce/linux/${DOCKER_RELEASE}/dists/" | grep link | awk -F 'title=' '{print $2}' | cut -d '"' -f 2)
    #curl -Lv https://download.docker.com/linux/${DOCKER_RELEASE}/gpg | apt-key add -
    #if [ ! $(command -v lsb_release) ]; then
    #   apt update
    #  apt install lsb-release
    #fi
    DOCKER_LIST=$(printf "%s\n" $DOCKER_TUNA_CODE_LIST | sed "s@\$@ .deb@g" | tr '\n' ' ')
    DOCKER_CODE=$(
        whiptail --title "DISTRO CODE & DOCKER VERSION" --menu \
            "Which version do you want to choose?" 0 0 0 \
            ${DOCKER_LIST} \
            3>&1 1>&2 2>&3
    )
    curl -Lv https://mirrors.bfsu.edu.cn/docker-ce/linux/${DOCKER_RELEASE}/gpg | apt-key add -
    cd /etc/apt/sources.list.d/
    sed -i 's/^deb/# &/g' docker.list 2>/dev/null
    #case "$(lsb_release -cs)" in
    #sid) DOCKER_CODE="buster" ;;
    #esac
    if (whiptail --title "请选择软件源" --yes-button "bfsu" --no-button "docker.com" --yesno "Please choose docker software source." 0 50); then
        printf "%s\n" "deb https://mirrors.bfsu.edu.cn/docker-ce/linux/${DOCKER_RELEASE} ${DOCKER_CODE} stable" >>docker.list
    else
        printf "%s\n" "deb https://download.docker.com/linux/${DOCKER_RELEASE} ${DOCKER_CODE} stable" >>docker.list
    fi
}
#################
check_docker_installation() {
    if [ ! "$(command -v docker)" ]; then
        printf "%s\n" "检测到您尚未安装docker，请先安装docker"
        install_docker_ce_or_io
    fi
}
############
install_docker_portainer() {
    check_docker_installation
    TARGET_PORT=$(whiptail --inputbox "请设定访问端口号,例如39080,默认内部端口为9000\n Please type the port." 0 50 --title "PORT" 3>&1 1>&2 2>&3)
    if [[ ${?} != 0 ]]; then
        ${RETURN_TO_WHERE}
    elif [ -z "${TARGET_PORT}" ]; then
        printf "%s\n" "端口无效，将自动使用39080端口。"
        printf "%s\n" "${RED}ERROR,the vaule is invalid.${RESET}"
        TARGET_PORT=39080
    fi
    printf "%s\n" "${GREEN}docker ${YELLOW}pull ${BLUE}portainer/portainer-ce:latest${RESET}"
    printf "%s\n" "${GREEN}docker ${RED}rm ${BLUE}portainer${RESET}"
    printf "%s\n" "${GREEN}docker ${BLUE}run -d -p ${YELLOW}${TARGET_PORT}:9000 ${BLUE}--name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest${RESET}"
    do_you_want_to_continue
    service docker start 2>/dev/null || systemctl start docker
    docker stop portainer 2>/dev/null
    docker pull portainer/portainer-ce:latest
    docker rm portainer
    docker run -d -p ${TARGET_PORT}:9000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
}
#####################
install_docker_io() {
    DEPENDENCY_01="docker.io"
    DEPENDENCY_02="docker"
    beta_features_quick_install
}
###########
install_docker_ce() {
    if [ ! $(command -v gpg) ]; then
        DEPENDENCY_01=""
        DEPENDENCY_02="gnupg"
        beta_features_quick_install
    fi
    DEPENDENCY_02="docker-ce"
    DEPENDENCY_01="docker"
    #apt remove docker docker-engine docker.io
    case "${LINUX_DISTRO}" in
    debian)
        DEPENDENCY_01="docker-ce"
        DEPENDENCY_02="docker-ce-cli docker"
        debian_add_docker_gpg
        ;;
    redhat)
        curl -Lv -o /etc/yum.repos.d/docker-ce.repo "https://download.docker.com/linux/${REDHAT_DISTRO}/docker-ce.repo"
        sed -i 's@download.docker.com@mirrors.bfsu.edu.cn/docker-ce@g' /etc/yum.repos.d/docker-ce.repo
        ;;
    arch)
        DEPENDENCY_01="docker"
        ;;
    alpine)
        DEPENDENCY_01="docker-engine docker-cli"
        DEPENDENCY_02="docker"
        ;;
    esac
    beta_features_quick_install
    if [ ! $(command -v docker) ]; then
        printf "%s\n" "安装失败，请执行${TMOE_INSTALLATION_COMMAND} docker.io"
    fi
}
#################
tmoe_docker_menu