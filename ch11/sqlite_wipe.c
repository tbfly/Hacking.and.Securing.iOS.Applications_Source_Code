#include <stdio.h>
#include <sqlite3.h>
#include <stdlib.h>
#include <string.h>

int main ()
{
    sqlite3 *dbh;
    int ret;
    ret = sqlite3_open("message.sqlite", &dbh);
    if (ret) {
        puts("sqlitedb open failed");
        exit(EXIT_FAILURE); 
    }

    ret = wipe_text_field(dbh, "messages", "message", 1);
    if (ret) {
        puts("wipe of field failed");
        exit(EXIT_FAILURE);
    }
    puts("wipe of field succeeded");
    return EXIT_SUCCESS;
}

int wipe_text_field(
    sqlite3 *dbh,
    const char *table,
    const char *field,
    int rowid)
{
    sqlite3_stmt *stmt;
    char scratch[128];
    int ret, step, len;

    snprintf(scratch, sizeof(scratch),
        "SELECT LENGTH(%s) FROM %s WHERE ROWID = %d",
        field, table, rowid);

    ret = sqlite3_prepare_v2(dbh, scratch, strlen(scratch), &stmt, 0);
    if (ret)
        return ret;

    step = sqlite3_step(stmt);
    if (step == SQLITE_ROW) {
        len = atoi(sqlite3_column_text(stmt, 0));
    } else {
        return -1; /* No such field found, or other error */ 
    }

    snprintf(scratch, sizeof(scratch),
        "UPDATE %s SET %s = ZEROBLOB(%d) WHERE ROWID = %d",
        table, field, len, rowid);

    return sqlite3_exec(dbh, scratch, 0, 0, 0);
}
    
