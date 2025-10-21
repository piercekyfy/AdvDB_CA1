using CouchDB.Driver.Types;
using Newtonsoft.Json;

public class Device : CouchDocument
{
    [JsonProperty("brand_name")]
    public string BrandName { get; set; }
    [JsonProperty("model_name")]
    public string ModelName { get; set; }
    [JsonProperty("imageUrl")]
    public string ImageUrl { get; set; } = string.Empty;
}