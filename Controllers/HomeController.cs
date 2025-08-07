using Microsoft.AspNetCore.Mvc;

namespace DockerPOC.Controllers;

[ApiController]
[Route("[controller]")]
public class HomeController : ControllerBase
{
    private readonly ILogger<HomeController> _logger;

    public HomeController(ILogger<HomeController> logger)
    {
        _logger = logger;
    }

    /// <summary>
    /// Returns a simple success message
    /// </summary>
    /// <returns>Success message</returns>
    [HttpGet]
    public IActionResult Get()
    {
        _logger.LogInformation("Home API endpoint called at {Time}", DateTime.UtcNow);
        
        // BREAKPOINT HERE - Click in the left margin next to this line
        var message = "success";
        
        return Ok(message + "test");
    }

    /// <summary>
    /// Test endpoint for debugging
    /// </summary>
    /// <returns>Debug info</returns>
    [HttpGet("debug")]
    public IActionResult Debug()
    {
        // BREAKPOINT TEST - Try adding breakpoint here
        var debugInfo = new
        {
            Time = DateTime.UtcNow,
            Environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT"),
            MachineName = Environment.MachineName
        };
        
        return Ok(debugInfo);
    }
} 