using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using CouchDB.Driver.Extensions;
using StackExchange.Redis;

// Setup Redis
RedisValue ImageUrlKey = new RedisValue("image");

using var redis = ConnectionMultiplexer.Connect("localhost");
IDatabase rdb = redis.GetDatabase();


DotNetEnv.Env.Load();

await using var context = new DevicesContext();

var devices = await context.Devices.Where(device => device.BrandName == "Acer").ToListAsync();

Console.WriteLine("`\n\tFinding all devices of brand 'Acer':\n");

Console.WriteLine($"Found {devices.Count}...");
for (int i = 0; i < Math.Min(3, devices.Count); i++)
{
    Device device = devices[i];
    Console.WriteLine($"[Id: {device.Id}, Brand: {device.BrandName}, Model: {device.ModelName}]");
}

async Task<string> getImageUrl(string deviceBrand, string deviceName)
{
    // Check Redis Cache
    RedisValue image = await rdb.HashGetAsync($"{deviceBrand}:{deviceName}", ImageUrlKey);
    if (!image.IsNull)
    {
        Console.WriteLine("Cache Hit!"); // Debug statement to see when cache is hit.
        return image;
    }

    // Otherwise find with expensive mango query
    Device device = await context.Devices
        .Where(device => device.BrandName == deviceBrand && device.ModelName == deviceName).Take(1).FirstOrDefaultAsync();

    if (device == null)
        return null;

    string imageUrl = device.ImageUrl ?? "";
        
    // Cache result
    RedisKey key = $"{deviceBrand}:{deviceName}";
    rdb.HashSet(key,
    [
        new HashEntry(ImageUrlKey, imageUrl)
    ]);
    rdb.KeyExpire(key, TimeSpan.FromSeconds(5)); // Expire after five seconds.

    return imageUrl;
}


Console.WriteLine("`\n\tGetting ImageUrl of 'Super ZX' of 'Acer' and caching result:\n");
Console.WriteLine(await getImageUrl("Acer", "Super ZX"));
Console.WriteLine("`\n\tTry it again!:\n");
Console.WriteLine(await getImageUrl("Acer", "Super ZX"));
Console.WriteLine("`\n\tWait six seconds...\n");
await Task.Delay(TimeSpan.FromSeconds(6));
Console.WriteLine("`\n\tTry it again!:\n");
Console.WriteLine(await getImageUrl("Acer", "Super ZX"));