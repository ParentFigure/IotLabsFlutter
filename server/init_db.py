import db


def main() -> None:
    db.initialize()
    print('MySQL database is ready.')


if __name__ == '__main__':
    main()
