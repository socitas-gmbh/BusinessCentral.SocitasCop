using Microsoft.Dynamics.Nav.CodeAnalysis;
using Microsoft.Dynamics.Nav.CodeAnalysis.Syntax;
using Microsoft.Dynamics.Nav.CodeAnalysis.Diagnostics;
using System.Collections.Immutable;

namespace BusinessCentral.SocitasCop;

[DiagnosticAnalyzer]
public class Rule0002NoLockTimeOut : DiagnosticAnalyzer
{
    public override ImmutableArray<DiagnosticDescriptor> SupportedDiagnostics { get; } =
        ImmutableArray.Create<DiagnosticDescriptor>(DiagnosticDescriptors.Rule0002NoLockTimeOut);

    public override void Initialize(AnalysisContext context) => context.RegisterOperationAction(new Action<OperationAnalysisContext>(this.CheckLockTimeout), OperationKind.InvocationExpression);

    private void CheckLockTimeout(OperationAnalysisContext ctx)
    {
        // Check if object is pending or obsolete        
        if (ctx.ContainingSymbol.GetContainingObjectTypeSymbol().IsObsoletePending || ctx.ContainingSymbol.GetContainingObjectTypeSymbol().IsObsoletePendingMove || ctx.ContainingSymbol.GetContainingObjectTypeSymbol().IsObsoleteRemoved || ctx.Operation is not IInvocationExpression operation)
        {
            return;
        }

        if (operation.TargetMethod.MethodKind != MethodKind.BuiltInMethod ||
            operation.TargetMethod.Name != "LockTimeout")
            return;

        ctx.ReportDiagnostic(Diagnostic.Create(DiagnosticDescriptors.Rule0002NoLockTimeOut, ctx.Operation.Syntax.GetLocation()));
    }

    public static class DiagnosticDescriptors
    {
        public static readonly DiagnosticDescriptor Rule0002NoLockTimeOut = new(
            id: "SO0002",
            title: "No LockTimeout",
            messageFormat: "Try to avoid LockTimeout.",
            category: "Design",
            defaultSeverity: DiagnosticSeverity.Warning, isEnabledByDefault: true,
            description: "Try to avoid LockTimeout.",
            helpLinkUri: "https://some.url/SO0002");
    }
}