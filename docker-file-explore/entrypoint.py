def sub_main():
    print('From submain called in main')


def main():
    sub_main()
    print('Entry point called main function called')


if __name__ == "__main__":
    main()