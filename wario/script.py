# python3 script.py CRACKME_MOD.COM
import sys

def main():
    if len(sys.argv) != 2:
        print("Использование: python patch.py <output.com>")
        return

    input_file = "/Users/dmitryershov/Desktop/dosbox/DOSBox/Doc/CRACKME.COM"
    output_file = "/Users/dmitryershov/Desktop/dosbox/DOSBox/Doc/" + sys.argv[1]

    # Смещение в файле (в байтах), где начинается пароль
    OFFSET = 0x9F  # = 0x19F (адрес в памяти) - 0x100 (org)

    with open(input_file, 'rb') as f:
        data = bytearray(f.read())

    if OFFSET + 11 > len(data):
        print("Ошибка: смещение выходит за границы файла")
        return

    # Записываем 11 символов 'b'
    for i in range(11):
        data[OFFSET + i] = ord('b')

    with open(output_file, 'wb') as f:
        f.write(data)

    print(f"Готово: 11 байт 'b' записаны по смещению 0x{OFFSET:X}")

if __name__ == '__main__':
    main()
