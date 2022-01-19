import sqlite3
import logging


def create_database(name="database.db"):
    with sqlite3.connect("database.db") as conn:
        logging.info("Creating new database.db...")
        conn.execute(
            "CREATE TABLE payments (uuid TEXT, fiat_value DECIMAL, btc_value DECIMAL, method TEXT, address TEXT, time DECIMAL, webhook TEXT, rhash TEXT)"
        )
    return


def write_to_database(invoice, name="database.db"):
    with sqlite3.connect("database.db") as conn:
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO payments (uuid,fiat_value,btc_value,method,address,time,webhook,rhash) VALUES (?,?,?,?,?,?,?,?)",
            (
                invoice["uuid"],
                invoice["fiat_value"],
                invoice["btc_value"],
                invoice["method"],
                invoice["address"],
                invoice["time"],
                invoice["webhook"],
                invoice["rhash"],
            ),
        )
    return


def load_invoice_from_db(uuid):
    with sqlite3.connect("database.db") as conn:
        conn.row_factory = sqlite3.Row
        cur = conn.cursor()
        rows = cur.execute(
            "SELECT * FROM payments WHERE uuid='{}'".format(uuid)
        ).fetchall()
    if len(rows) > 0:
        return [dict(ix) for ix in rows][0]
    else:
        return None


def check_address_table_exists():
    with sqlite3.connect("database.db") as conn:
        exists = conn.execute(
            f"SELECT name FROM sqlite_master WHERE type='table' AND name='addresses'"
        ).fetchall()
        if len(exists) == 0:
            return False

    return exists


def create_address_table():
    with sqlite3.connect("database.db") as conn:
        logging.info("Creating new table for generated addresses")
        conn.execute("CREATE TABLE addresses (n INTEGER, address TEXT)")
    return


def add_generated_address(index, address):
    with sqlite3.connect("database.db") as conn:
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO addresses (n, address) VALUES (?,?)",
            (
                index,
                address,
            ),
        )
    return


def get_next_address_index():
    with sqlite3.connect("database.db") as conn:
        conn.row_factory = sqlite3.Row
        cur = conn.cursor()
        addresses = cur.execute("SELECT * FROM addresses").fetchall()

    if len(addresses) == 0:
        return 0
    else:
        return max([dict(addr)["n"] for addr in addresses]) + 1
