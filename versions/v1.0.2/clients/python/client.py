"""
Prisma Client for Python
"""

import os
import psycopg
from typing import List, Dict, Any, Optional

class PrismaClient:
    def __init__(self, database_url: str = None):
        self.database_url = database_url or os.getenv("DATABASE_URL")
        if not self.database_url:
            raise ValueError("DATABASE_URL environment variable is required")
    
    def connect(self):
        """Create database connection"""
        return psycopg.connect(self.database_url)
    
    def find_many_customers(self, **filters) -> List[Dict[str, Any]]:
        """Find multiple customers with optional filters"""
        with self.connect() as conn:
            with conn.cursor() as cur:
                query = "SELECT * FROM \"Customer\""
                params = []
                
                if filters:
                    conditions = []
                    for key, value in filters.items():
                        if value is not None:
                            conditions.append(f'"{key}" = %s')
                            params.append(value)
                    
                    if conditions:
                        query += " WHERE " + " AND ".join(conditions)
                
                cur.execute(query, params)
                columns = [desc[0] for desc in cur.description]
                return [dict(zip(columns, row)) for row in cur.fetchall()]
    
    def find_many_companies(self, **filters) -> List[Dict[str, Any]]:
        """Find multiple companies with optional filters"""
        with self.connect() as conn:
            with conn.cursor() as cur:
                query = "SELECT * FROM \"Company\""
                params = []
                
                if filters:
                    conditions = []
                    for key, value in filters.items():
                        if value is not None:
                            conditions.append(f'"{key}" = %s')
                            params.append(value)
                    
                    if conditions:
                        query += " WHERE " + " AND ".join(conditions)
                
                cur.execute(query, params)
                columns = [desc[0] for desc in cur.description]
                return [dict(zip(columns, row)) for row in cur.fetchall()]
    
    def find_many_prospects(self, **filters) -> List[Dict[str, Any]]:
        """Find multiple prospects with optional filters"""
        with self.connect() as conn:
            with conn.cursor() as cur:
                query = "SELECT * FROM \"Prospect\""
                params = []
                
                if filters:
                    conditions = []
                    for key, value in filters.items():
                        if value is not None:
                            conditions.append(f'"{key}" = %s')
                            params.append(value)
                    
                    if conditions:
                        query += " WHERE " + " AND ".join(conditions)
                
                cur.execute(query, params)
                columns = [desc[0] for desc in cur.description]
                return [dict(zip(columns, row)) for row in cur.fetchall()]
    
    def create_customer(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new customer"""
        with self.connect() as conn:
            with conn.cursor() as cur:
                columns = list(data.keys())
                placeholders = ["%s"] * len(columns)
                values = list(data.values())
                
                query = f"""
                    INSERT INTO "Customer" ({', '.join(f'"{col}"' for col in columns)})
                    VALUES ({', '.join(placeholders)})
                    RETURNING *
                """
                
                cur.execute(query, values)
                columns = [desc[0] for desc in cur.description]
                result = dict(zip(columns, cur.fetchone()))
                conn.commit()
                return result
    
    def create_company(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new company"""
        with self.connect() as conn:
            with conn.cursor() as cur:
                columns = list(data.keys())
                placeholders = ["%s"] * len(columns)
                values = list(data.values())
                
                query = f"""
                    INSERT INTO "Company" ({', '.join(f'"{col}"' for col in columns)})
                    VALUES ({', '.join(placeholders)})
                    RETURNING *
                """
                
                cur.execute(query, values)
                columns = [desc[0] for desc in cur.description]
                result = dict(zip(columns, cur.fetchone()))
                conn.commit()
                return result
    
    def create_prospect(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new prospect"""
        with self.connect() as conn:
            with conn.cursor() as cur:
                columns = list(data.keys())
                placeholders = ["%s"] * len(columns)
                values = list(data.values())
                
                query = f"""
                    INSERT INTO "Prospect" ({', '.join(f'"{col}"' for col in columns)})
                    VALUES ({', '.join(placeholders)})
                    RETURNING *
                """
                
                cur.execute(query, values)
                columns = [desc[0] for desc in cur.description]
                result = dict(zip(columns, cur.fetchone()))
                conn.commit()
                return result
