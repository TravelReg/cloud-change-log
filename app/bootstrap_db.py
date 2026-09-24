import os

import psycopg
from psycopg import sql


ROLE_NAME = "ccl_app"


def main():
    with psycopg.connect(
        host=os.environ["DB_HOST"],
        dbname=os.environ["DB_NAME"],
        user=os.environ["MASTER_DB_USER"],
        password=os.environ["MASTER_DB_PASSWORD"],
        sslmode="require",
    ) as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT 1 FROM pg_roles WHERE rolname = %s",
                (ROLE_NAME,),
            )

            password = sql.Literal(os.environ["DB_PASSWORD"])
            role = sql.Identifier(ROLE_NAME)

            if cursor.fetchone():
                cursor.execute(
                    sql.SQL("ALTER ROLE {} WITH PASSWORD {}").format(
                        role, password
                    )
                )
            else:
                cursor.execute(
                    sql.SQL("CREATE ROLE {} WITH LOGIN PASSWORD {}").format(
                        role, password
                    )
                )

            cursor.execute(
                sql.SQL("GRANT CONNECT ON DATABASE {} TO {}").format(
                    sql.Identifier(os.environ["DB_NAME"]), role
                )
            )
            cursor.execute(
                sql.SQL("GRANT USAGE, CREATE ON SCHEMA public TO {}").format(
                    role
                )
            )

    print("ccl_app database role is ready")


if __name__ == "__main__":
    main()