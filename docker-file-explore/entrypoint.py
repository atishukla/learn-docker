import os


def sub_main():
    print(f"Hello {os.environ['HELLO']}")


def main():
    sub_main()
    print('Entry point called main function called')


if __name__ == "__main__":
    main()