using Microsoft.Dynamics.Nav.CodeAnalysis;
using Microsoft.Dynamics.Nav.CodeAnalysis.Syntax;
using Microsoft.Dynamics.Nav.CodeAnalysis.Diagnostics;
using System.Collections.Immutable;

namespace SocitasCodeCop;

[DiagnosticAnalyzer]
public class Rule0001VariableNaming : DiagnosticAnalyzer
{
    public override ImmutableArray<DiagnosticDescriptor> SupportedDiagnostics { get; } = 
        ImmutableArray.Create<DiagnosticDescriptor>(DiagnosticDescriptors.Rule0001VariableNameShouldNotStartWithLorG);

    public override void Initialize(AnalysisContext context) => context.RegisterSyntaxNodeAction(new Action<SyntaxNodeAnalysisContext>(this.AnalyzeLocalVariableNaming), SyntaxKind.VariableDeclaration);

    private void AnalyzeLocalVariableNaming(SyntaxNodeAnalysisContext ctx)
    {                
        // Check if object is pending or obsolete        
        if (ctx.ContainingSymbol.GetContainingObjectTypeSymbol().IsObsoletePending || ctx.ContainingSymbol.GetContainingObjectTypeSymbol().IsObsoletePendingMove || ctx.ContainingSymbol.GetContainingObjectTypeSymbol().IsObsoleteRemoved) {
            return;
        }
                
        VariableDeclarationSyntax syntax = ctx.Node as VariableDeclarationSyntax;        
        if (syntax != null)
        {            
            string variableName = syntax.GetNameStringValue();
            if (variableName.StartsWith('l') || variableName.StartsWith('g'))
            {
                ctx.ReportDiagnostic(Diagnostic.Create(DiagnosticDescriptors.Rule0001VariableNameShouldNotStartWithLorG, syntax.Name.GetLocation(), syntax.Name));                
            }
        }
    }

    public static class DiagnosticDescriptors
    {
        public static readonly DiagnosticDescriptor Rule0001VariableNameShouldNotStartWithLorG = new(
            id: "SO0001",
            title: "l or g Variable",
            messageFormat: "No variable name should start with l or g",
            category: "Design",
            defaultSeverity: DiagnosticSeverity.Warning, isEnabledByDefault: true,
            description: "No variable name should start with l or g",
            helpLinkUri: "https://some.url/SO0001");
    }
}