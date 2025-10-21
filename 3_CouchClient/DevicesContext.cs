using System;
using CouchDB.Driver;
using CouchDB.Driver.Options;

public class DevicesContext : CouchContext
{
    public CouchDatabase<Device> Devices { get; set; }

    protected override void OnConfiguring(CouchOptionsBuilder optionsBuilder)
    {
        optionsBuilder
            .UseEndpoint("http://localhost:5984")
            .EnsureDatabaseExists()
            .UseBasicAuthentication(username: DotNetEnv.Env.GetString("COUCHDB_USER"), password: DotNetEnv.Env.GetString("COUCHDB_PASS"));
    }

    protected override void OnDatabaseCreating(CouchDatabaseBuilder databaseBuilder)
    {
        databaseBuilder.Document<Device>().ToDatabase("phones");
    }
}