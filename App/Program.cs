using App.Services.LanguageService;
using App;

var key = "your-key";
var endpoint = "your-endpoint";

var languageService = new LanguageService(endpoint, key);

foreach (var comment in Comment.Items)
{
    var result = await languageService.AnalyseAsync(comment);    
    Console.WriteLine($"{comment} - {result.Language} - {result.Sentiment}");
}