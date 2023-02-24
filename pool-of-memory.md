
### 2023.02.24

Установка Magisk на Google Pixel 7

1. Скачать прошивку, распаковать zip
2. Если есть `payload.bin`, то сделать `payload-dumper-go payload.bin`
3. Кладём `boot.img` на телефон - `./adb push PATH-TO-EXTRACTED-PAYLOAD-BIN/init_boot.img /sdcard/`
4. На телефоне открываем Magisk и патчим `boot.img`
5. Берём с телефона пропатченный `boot.img` - `./adb pull /storage/emulated/0/Download/magisk_patched-VERSION_RANDOM.img SOMEWHERE/`
6. Грузимся в fastboot - `./adb reboot fastboot`
7. Патчим ядро - `./fastboot flash init_boot SOMEWHERE/magisk_patched-VERSION_RANDOM.img`
8. Грузимся в систему - `./fastboot reboot`
9. Проверяем в Termux - `su`, в самом Magisk признаков успешной установки может и не быть

https://4pda.to/forum/index.php?showtopic=1056929&st=40#entry118659642
https://4pda.to/forum/index.php?showtopic=1056929&st=0#entry118196601

### 2023.01.06

Доступ до lan за клиентом openvpn на keenetic - допилка
https://help.keenetic.com/hc/ru/articles/360001084700-%D0%9F%D1%80%D0%B8%D0%BC%D0%B5%D1%80-%D0%BD%D0%B0%D1%81%D1%82%D1%80%D0%BE%D0%B9%D0%BA%D0%B8-%D0%B4%D0%BE%D1%81%D1%82%D1%83%D0%BF%D0%B0-%D0%BC%D0%B5%D0%B6%D0%B4%D1%83-%D0%BB%D0%BE%D0%BA%D0%B0%D0%BB%D1%8C%D0%BD%D1%8B%D0%BC%D0%B8-%D1%81%D0%B5%D1%82%D1%8F%D0%BC%D0%B8-%D0%B8%D0%BD%D1%82%D0%B5%D1%80%D0%BD%D0%B5%D1%82-%D1%86%D0%B5%D0%BD%D1%82%D1%80%D0%BE%D0%B2-Keenetic-%D1%81-%D0%BF%D0%BE%D0%BC%D0%BE%D1%89%D1%8C%D1%8E-%D1%80%D0%B0%D1%81%D0%BF%D0%BE%D0%BB%D0%BE%D0%B6%D0%B5%D0%BD%D0%BD%D0%BE%D0%B3%D0%BE-%D0%B2-%D0%BE%D0%B1%D0%BB%D0%B0%D1%87%D0%BD%D0%BE%D0%BC-%D1%85%D0%BE%D1%81%D1%82%D0%B8%D0%BD%D0%B3%D0%B5-%D1%81%D0%B5%D1%80%D0%B2%D0%B5%D1%80%D0%B0-OpenVPN

### когда-то

kvm port forwarding
https://serverfault.com/questions/170079/forwarding-ports-to-guests-in-libvirt-kvm
https://www.cyberciti.biz/faq/kvm-forward-ports-to-guests-vm-with-ufw-on-linux/

```bash
# сначала нужно установить netfilter-persistent

# настраиваем проброс портов
sudo iptables -t nat -I PREROUTING -p tcp -d EXTERNALIP --dport EXTERNALPORT -j DNAT --to-destination INTERNALIP:INTERNALPORT

# в первый раз
sudo iptables -L FORWARD -nv --line-number
sudo iptables -t nat -L PREROUTING -n -v --line-number

# сохраняем, чтобы применилось после перезапуска хоста
sudo service netfilter-persistent save
```

