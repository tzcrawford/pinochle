#!/usr/bin/env python
from warnings import warn
import pandas as pd # Doc: https://pandas.pydata.org/docs/
import sqlalchemy # Doc: https://docs.sqlalchemy.org/en/14/index.html
#print(sqlalchemy.__version__) #1.4.40 at time of writing
import keyring
import json

config_file = "config.json"

with open(config_file) as config_json:
    config = json.load(config_json)

# Collect password for db queries
db_password = keyring.get_password

class SQLConnection:
    def __init__(self, config=config, db_password=db_password, get_engine_auto=True):
        
        self.port       = config['postgresPort']
        self.host       = config['postgresHost']
        self.DBName     = config['postgresDBName']
        self.DBLocation = config['postgresDBLocation']
        self.Locale     = config['postgresLocale']
        self.Encoding   = config['postgresEncoding']
        self.user       = config['postgresUsername']
        self.password   = db_password

        self.url = f"postgresql://{self.user}:{self.password}@{self.host}:{self.port}/{self.DBName}"
        self.pool_size=50

        if get_engine_auto:
            self.get_engine()

    def get_engine(self):
        self.engine = sqlalchemy.create_engine(
            self.url, \
            pool_size=self.pool_size,
            echo=False
        )
        
        #This uses the SQLAlchemy 2.0 (not supported by pandas at this time)
        self.engine2 = sqlalchemy.create_engine(
            self.url, \
            pool_size=self.pool_size,
            echo=False,
            future=True
        )
    
    # Runs a command and returns in plain text (python list for multiple rows)
    # Can be a select, alter table, anything like that
    def execute(self, command, params=False, commit=True): 
        # Make a connection object with the server
        with self.engine2.connect() as conn:
        
            # Can send some parameters along with a plain text query... 
                # could be single dict or list of dict
                # Doc: https://docs.sqlalchemy.org/en/14/tutorial/dbapi_transactions.html#sending-multiple-parameters
            if params:
                output = conn.execute(sqlalchemy.text(command,params))
            else:
                output = conn.execute(sqlalchemy.text(command))
            
            # Tell postgresSQL to save your changes (assuming that is applicable, is not with select)
            # Doc: https://docs.sqlalchemy.org/en/14/tutorial/dbapi_transactions.html#committing-changes
            if commit:
                try:
                    conn.commit()
                except Exception as e:
                    #pass
                    warn("Could not commit changes...\n" + str(e))
           
            # Try to consolidate select statement result into single object to return
            try:
                output = output.all()
            except:
                pass
        return output

    
    # Return a pandas dataframe from a selection
    def select(self, command): 
        # Note this currently must use the legacy type 1.0 SQLAlchemy engine (not engine2)
        return pd.read_sql(sql=command, con=self.engine) #w sqlalchemy
   
    # Take python pandas object and convert that to a SQL table
    def write_to_table(self, table_name, df, if_exists='fail'):
        # if_exists: How to behave if the table already exists.
        #     fail: Raise a ValueError.
        #     replace: Drop the table before inserting new values.
        #     append: Insert new values to the existing table.
        return df.to_sql(table_name, self.engine, index=False, if_exists=if_exists)
    
    # Take python pandas object and append that to existing SQL table
    def append_to_table(self, table_name, df):
        return self.write_to_table(table_name, df, if_exists='append')

