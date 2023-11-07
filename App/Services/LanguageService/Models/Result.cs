namespace App.Services.LanguageService.Models;

public record Result
{
    public Sentiment Sentiment { get; init; }
    public string Language { get; init; } = default!;
}