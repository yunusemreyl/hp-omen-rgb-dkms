cat > install.sh << 'EOF'
#!/bin/bash

# Renk Tanımlamaları
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

MODULE_NAME="hp-omen-rgb"
MODULE_VERSION="1.0"
SRC_DEST="/usr/src/${MODULE_NAME}-${MODULE_VERSION}"

echo -e "${GREEN}>>> HP Omen/Victus RGB Driver Installer v1.0${NC}"

# 1. Root Yetkisi Kontrolü
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Hata: Bu script sudo/root yetkisi ile çalıştırılmalıdır.${NC}" 
   exit 1
fi

# 2. Bağımlılıkların Kurulması (Dağıtım Algılama)
echo ">>> Bağımlılıklar kontrol ediliyor..."
if [ -f /etc/debian_version ]; then
    apt update -qq && apt install -y dkms linux-headers-$(uname -r) build-essential
elif [ -f /etc/arch-release ]; then
    pacman -S --noconfirm dkms linux-headers base-devel
elif [ -f /etc/fedora-release ]; then
    dnf install -y dkms kernel-devel kernel-headers gcc make
else
    echo -e "${RED}Uyarı: Dağıtım tam olarak algılanamadı, DKMS ve Headers paketlerini manuel kurmanız gerekebilir.${NC}"
fi

# 3. Eski Sürüm Temizliği
echo ">>> Eski sürümler temizleniyor..."
dkms remove ${MODULE_NAME}/${MODULE_VERSION} --all > /dev/null 2>&1
rm -rf ${SRC_DEST}

# 4. Dosyaları Sisteme Kopyalama
echo ">>> Kaynak dosyalar kopyalanıyor: ${SRC_DEST}"
mkdir -p ${SRC_DEST}
cp -r . ${SRC_DEST}/

# Kurulum scriptlerini sistem klasöründe tutmaya gerek yok
rm -f ${SRC_DEST}/install.sh
rm -f ${SRC_DEST}/uninstall.sh

# 5. DKMS İşlemleri
echo ">>> DKMS derleme ve kurulum süreci başlıyor..."
dkms add -m ${MODULE_NAME} -v ${MODULE_VERSION}
dkms build -m ${MODULE_NAME} -v ${MODULE_VERSION}
dkms install -m ${MODULE_NAME} -v ${MODULE_VERSION}

# 6. Modülü Aktif Etme ve Başlangıca Ekleme
echo ">>> Sürücü yükleniyor..."
modprobe -r ${MODULE_NAME} 2>/dev/null
modprobe ${MODULE_NAME}

# Boot sırasında otomatik yüklenmesi için conf oluştur
echo "${MODULE_NAME}" > /etc/modules-load.d/${MODULE_NAME}.conf

# 7. Sonuç Kontrolü
if lsmod | grep -q "${MODULE_NAME}"; then
    echo -e "${GREEN}>>> BAŞARILI! Sürücü aktif ve boot sırasında otomatik yüklenecek.${NC}"
    echo -e "Test: echo 'FF0000' | sudo tee /sys/devices/platform/hp-omen-rgb/zone0"
else
    echo -e "${RED}>>> HATA! Modül yüklenemedi. 'dmesg' komutuyla hataları kontrol edin.${NC}"
fi
EOF
chmod +x install.sh
