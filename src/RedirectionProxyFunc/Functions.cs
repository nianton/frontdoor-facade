using System;
using System.IO;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace RedirectionProxyFunc
{
    public static class Functions
    {
        static readonly HttpClient Client = new HttpClient();
        static readonly string BackendBaseUrl = Environment.GetEnvironmentVariable("BackendBaseUrl");

        [FunctionName("HealthProbe")]
        public static async Task<IActionResult> HealthProbe(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = "health")] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");
            var response = await Client.GetAsync($"http://{BackendBaseUrl}");
            if (response.IsSuccessStatusCode)
                return new OkObjectResult("ok");
            
            return new StatusCodeResult(StatusCodes.Status503ServiceUnavailable);
        }


        [FunctionName("Debug")]
        public static IActionResult Debug(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = "debug")] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");
            return new OkObjectResult(new { BackendBaseUrl });
        }
    }
}
