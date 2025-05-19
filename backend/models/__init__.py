"""
Database models initialization
"""
from flask import g

def query_db(query, args=(), one=False):
    """Execute a query and return the results"""
    cursor = g.db.cursor()
    cursor.execute(query, args)
    rv = [dict(zip([column[0] for column in cursor.description], row)) 
          for row in cursor.fetchall()]
    cursor.close()
    return (rv[0] if rv else None) if one else rv

def execute_db(query, args=()):
    """Execute a query without returning results"""
    cursor = g.db.cursor()
    cursor.execute(query, args)
    last_id = cursor.execute("SELECT @@IDENTITY").fetchval()
    cursor.close()
    return last_id
