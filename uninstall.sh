cat > uninstall.sh << 'EOF'
#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

MODULE_NAME="hp-omen-rgb"
MODULE_VERSION="1.0"

echo -e "${RED}>>> HP Omen/Victus RGB Driver Kaldırılıyor...${NC}"

if [[ $EUID -ne 0 ]]; then
   echo "Lütfen sudo ile çalıştırın." 
   exit 1
fi

# 1. Modülü Durdur
modprobe -r ${MODULE_NAME} 2>/dev/null

# 2. DKMS Kaydını Sil
dkms remove ${MODULE_NAME}/${MODULE_VERSION} --all

# 3. Kaynak Dosyaları Temizle
rm -rf /usr/src/${MODULE_NAME}-${MODULE_VERSION}

# 4. Başlangıç Ayarını Sil
rm -f /etc/modules-load.d/${MODULE_NAME}.conf

echo -e "${GREEN}>>> İşlem Tamamlandı. Sürücü sistemden tamamen kaldırıldı.${NC}"
EOF
chmod +x uninstall.sh
