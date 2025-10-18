# https://docs.snowflake.com/developer-guide/python-connector/python-connector-example#sample-program
import logging
import os
import sys


# -- (> ---------------------- SECTION=import_connector ---------------------
import snowflake.connector
# -- <) ---------------------------- END_SECTION ----------------------------


class python_veritas_base:

    def __init__(self, p_log_file_name = None):

        file_name = p_log_file_name
        if file_name is None:
            file_name = '/tmp/snowflake_python_connector.log'

        # -- (> ---------- SECTION=begin_logging -----------------------------
        logging.basicConfig(
            filename=file_name,
            level=logging.INFO)
        # -- <) ---------- END_SECTION ---------------------------------------


    # -- (> ---------------------------- SECTION=main ------------------------
    def main(self, argv):

        """
        PURPOSE:
            Most tests follow the same basic pattern in this main() method:
               * Create a connection.
               * Set up, e.g. use (or create and use) the warehouse, database,
                 and schema.
               * Run the queries (or do the other tasks, e.g. load data).
               * Clean up. In this test/demo, we drop the warehouse, database,
                 and schema. In a customer scenario, you'd typically clean up
                 temporary tables, etc., but wouldn't drop your database.
               * Close the connection.
        """

        # Read the connection parameters (e.g. user ID) from the command line
        # and environment variables, then connect to Snowflake.
        connection = self.create_connection(argv)

        # Set up anything we need (e.g. a separate schema for the test/demo).
        self.set_up(connection)

        # Do the "real work", for example, create a table, insert rows, SELECT
        # from the table, etc.
        self.do_the_real_work(connection)

        # Clean up. In this case, we drop the temporary warehouse, database, and
        # schema.
        self.clean_up(connection)

        print("\nClosing connection...")
        # -- (> ------------------- SECTION=close_connection -----------------
        connection.close()
        # -- <) ---------------------------- END_SECTION ---------------------

    # -- <) ---------------------------- END_SECTION=main --------------------


    def create_connection(self, argv):

        """
        PURPOSE:
            This gets account identifier and login information from the
            environment variables and command-line parameters, connects to the
            server, and returns the connection object.
        INPUTS:
            argv: This is usually sys.argv, which contains the command-line
                  parameters. It could be an equivalent substitute if you get
                  the parameter information from another source.
        RETURNS:
            A connection.
        """

        # Get account identifier and login information from environment variables and command-line parameters.
        # For information about account identifiers, see
        # https://docs.snowflake.com/en/user-guide/admin-account-identifier.html .
        # -- (> ----------------------- SECTION=set_login_info ---------------

        USER = os.getenv('SNOWSQL_USER')
        PASSWORD = os.getenv('SNOWSQL_PWD')
        ACCOUNT = os.getenv('SNOWSQL_ACCOUNT')
        WAREHOUSE = 'COMPUTE_WAREHOUSE'
        DATABASE = 'testdb_mg'

        # -- <) ---------------------------- END_SECTION ---------------------

        # Optional diagnostic:
        #print("USER:", USER)
        print("ACCOUNT:", ACCOUNT)
        #print("WAREHOUSE:", WAREHOUSE)
        #print("DATABASE:", DATABASE)
        #print("SCHEMA:", SCHEMA)
        #print("PASSWORD:", PASSWORD)
        #print("PROTOCOL:" "'" + PROTOCOL + "'")
        #print("PORT:" + "'" + PORT + "'")

        print("Connecting...")
        # -- (> ------------------- SECTION=connect_to_snowflake ---------
        conn = snowflake.connector.connect(
            user=USER,
            password=PASSWORD,
            account=ACCOUNT,
            # warehouse=WAREHOUSE,
            # database=DATABASE,
            # schema=SCHEMA
            )

        return conn


    def set_up(self, connection):

        """
        PURPOSE:
            Set up to run a test. You can override this method with one
            appropriate to your test/demo.
        """

        # Create a temporary warehouse, database, and schema.
        self.create_warehouse_database_and_schema(connection)


    def do_the_real_work(self, conn):

        """
        PURPOSE:
            Your sub-class should override this to include the code required for
            your documentation sample or your test case.
            This default method does a very simple self-test that shows that the
            connection was successful.
        """

        # Create a cursor for this connection.
        cursor1 = conn.cursor()
        # This is an example of an SQL statement we might want to run.
        command = "SELECT PI()"
        # Run the statement.
        cursor1.execute(command)
        # Get the results (should be only one):
        for row in cursor1:
            print(row[0])
        # Close this cursor.
        cursor1.close()


    def clean_up(self, connection):

        """
        PURPOSE:
            Clean up after a test. You can override this method with one
            appropriate to your test/demo.
        """

        # Create a temporary warehouse, database, and schema.
        self.drop_warehouse_database_and_schema(connection)


    def create_warehouse_database_and_schema(self, conn):

        """
        PURPOSE:
            Create the temporary schema, database, and warehouse that we use
            for most tests/demos.
        """

        # Create a database, schema, and warehouse if they don't already exist.
        print("\nCreating warehouse, database, schema...")
        # -- (> ------------- SECTION=create_warehouse_database_schema -------
        conn.cursor().execute("CREATE WAREHOUSE IF NOT EXISTS tiny_warehouse_mg")
        conn.cursor().execute("CREATE DATABASE IF NOT EXISTS testdb_mg")
        conn.cursor().execute("USE DATABASE testdb_mg")
        conn.cursor().execute("CREATE SCHEMA IF NOT EXISTS testschema_mg")
        # -- <) ---------------------------- END_SECTION ---------------------

        # -- (> --------------- SECTION=use_warehouse_database_schema --------
        conn.cursor().execute("USE WAREHOUSE tiny_warehouse_mg")
        conn.cursor().execute("USE DATABASE testdb_mg")
        conn.cursor().execute("USE SCHEMA testdb_mg.testschema_mg")
        # -- <) ---------------------------- END_SECTION ---------------------


    def drop_warehouse_database_and_schema(self, conn):

        """
        PURPOSE:
            Drop the temporary schema, database, and warehouse that we create
            for most tests/demos.
        """

        # -- (> ------------- SECTION=drop_warehouse_database_schema ---------
        conn.cursor().execute("DROP SCHEMA IF EXISTS testschema_mg")
        conn.cursor().execute("DROP DATABASE IF EXISTS testdb_mg")
        conn.cursor().execute("DROP WAREHOUSE IF EXISTS tiny_warehouse_mg")
        # -- <) ---------------------------- END_SECTION ---------------------


# ----------------------------------------------------------------------------

if __name__ == '__main__':
    pvb = python_veritas_base()
    pvb.main(sys.argv)
