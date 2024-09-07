### 2023.10.02

Реагирование на включение/выключения питания ноутбука от сети в Ubuntu

```
/etc/udev/rules.d/10-power.supply.rules

SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="[01]", RUN+="path-to-shell-script-to-run"
```

### 2023.03.04

Добавление даты-времени timestamp в логи openvpn

- https://www.oldfag.ru/2020/02/openvpn-timestamps-in-log.html
-  в `/lib/systemd/system/openvpn-server@.service` удалить `--suppress-timestamps`
- `sudo systemctl daemon-reload`
- `sudo systemctl restart openvpn-server@server`

### 2023.02.24

Установка Magisk на Google Pixel 7

- Скачать прошивку, распаковать zip
- Если есть `payload.bin`, то сделать `payload-dumper-go payload.bin`
- Кладём `boot.img` на телефон - `./adb push PATH-TO-EXTRACTED-PAYLOAD-BIN/init_boot.img /sdcard/`
- На телефоне открываем Magisk и патчим `boot.img`
- Берём с телефона пропатченный `boot.img` - `./adb pull /storage/emulated/0/Download/magisk_patched-VERSION_RANDOM.img SOMEWHERE/`
- Грузимся в fastboot - `./adb reboot fastboot`
- Патчим ядро - `./fastboot flash init_boot SOMEWHERE/magisk_patched-VERSION_RANDOM.img`
- Грузимся в систему - `./fastboot reboot`
- Проверяем в Termux - `su`, в самом Magisk признаков успешной установки может и не быть

https://4pda.to/forum/index.php?showtopic=1056929&st=40#entry118659642
https://4pda.to/forum/index.php?showtopic=1056929&st=0#entry118196601

### 2023.01.06

Доступ до lan за клиентом openvpn на keenetic - допилка
https://help.keenetic.com/hc/ru/articles/360001084700-%D0%9F%D1%80%D0%B8%D0%BC%D0%B5%D1%80-%D0%BD%D0%B0%D1%81%D1%82%D1%80%D0%BE%D0%B9%D0%BA%D0%B8-%D0%B4%D0%BE%D1%81%D1%82%D1%83%D0%BF%D0%B0-%D0%BC%D0%B5%D0%B6%D0%B4%D1%83-%D0%BB%D0%BE%D0%BA%D0%B0%D0%BB%D1%8C%D0%BD%D1%8B%D0%BC%D0%B8-%D1%81%D0%B5%D1%82%D1%8F%D0%BC%D0%B8-%D0%B8%D0%BD%D1%82%D0%B5%D1%80%D0%BD%D0%B5%D1%82-%D1%86%D0%B5%D0%BD%D1%82%D1%80%D0%BE%D0%B2-Keenetic-%D1%81-%D0%BF%D0%BE%D0%BC%D0%BE%D1%89%D1%8C%D1%8E-%D1%80%D0%B0%D1%81%D0%BF%D0%BE%D0%BB%D0%BE%D0%B6%D0%B5%D0%BD%D0%BD%D0%BE%D0%B3%D0%BE-%D0%B2-%D0%BE%D0%B1%D0%BB%D0%B0%D1%87%D0%BD%D0%BE%D0%BC-%D1%85%D0%BE%D1%81%D1%82%D0%B8%D0%BD%D0%B3%D0%B5-%D1%81%D0%B5%D1%80%D0%B2%D0%B5%D1%80%D0%B0-OpenVPN

### когда-то

kvm port forwarding
https://serverfault.com/questions/170079/forwarding-ports-to-guests-in-libvirt-kvm
https://www.cyberciti.biz/faq/kvm-forward-ports-to-guests-vm-with-ufw-on-linux/

07.09.2024 сработало вот это - https://askubuntu.com/questions/1065570/kvm-nat-port-forwarding

```bash
# ставим netfilter-persistent
sudo apt install iptables-persistent

iptables -t nat -I PREROUTING -p tcp -d HOST_IP --dport HOST_PORT -j DNAT --to-destination VM_IP:VM_PORT

# VM_SUBNET
iptables -I FORWARD -m state -d 192.168.122.0/24 --state NEW,RELATED,ESTABLISHED -j ACCEPT

service netfilter-persistent save
```

