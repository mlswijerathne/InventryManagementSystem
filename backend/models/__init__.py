"""
Database models initialization
"""
from flask import g

def query_db(query, args=(), one=False, timeout=None):
    """Execute a query and return the results"""
    cursor = g.db.cursor()
    
    # We now ignore the timeout parameter to avoid SQL syntax issues
    # and rely on the database's default timeout settings
    try:
        # Execute the actual query
        cursor.execute(query, args)
        if cursor.description:  # Check if query returns results
            rv = [dict(zip([column[0] for column in cursor.description], row)) 
                for row in cursor.fetchall()]
        else:
            rv = []
    except Exception as e:
        cursor.close()
        raise e
    cursor.close()
    return (rv[0] if rv else None) if one else rv

def execute_db(query, args=(), timeout=None):
    """Execute a query without returning results"""
    cursor = g.db.cursor()
    try:
        cursor.execute(query, args)
        last_id = cursor.execute("SELECT @@IDENTITY").fetchval()
    except Exception as e:
        cursor.close()
        raise e
    cursor.close()
    return last_id
