using System.Reflection.Metadata;
using App.Services.LanguageService.Models;
using Azure;
using Azure.AI.TextAnalytics;

namespace App.Services.LanguageService;

public class LanguageService 
{
    private readonly TextAnalyticsClient _client;

    public LanguageService(string endpoint, string key)
    {
        var credentials = new AzureKeyCredential(key);
        Uri uri = new Uri(endpoint);

        _client = new TextAnalyticsClient(uri, credentials);
    }

    public async Task<Result> AnalyseAsync(string value)
    {
        DetectedLanguage detectedLanguage = await  _client.DetectLanguageAsync(value);
        DocumentSentiment documentSentiment = await _client.AnalyzeSentimentAsync(value, language: detectedLanguage.Iso6391Name, options: new AnalyzeSentimentOptions()
        {
            
        });

        return new Result
        {
            Sentiment = documentSentiment.Sentiment switch
            {
                TextSentiment.Positive => Sentiment.Positive,
                TextSentiment.Negative => Sentiment.Negative,
                _ => Sentiment.Neutral,
            },
            Language = detectedLanguage.Name
        };
    }
}