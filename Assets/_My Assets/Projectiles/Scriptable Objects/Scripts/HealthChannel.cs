using Fusion;
using System;
using UnityEngine;

[CreateAssetMenu(fileName = "HealthChannel", menuName = "Channels/HealthChannel", order = 0)]
public class HealthChannel : ScriptableObject
{
    public Action OnPlayerDamaged;

    public void RaisePlayerDamaged() => OnPlayerDamaged?.Invoke();

    public Action<int> OnDamageRedTeam;
    public Action<int> OnDamageBlueTeam;

    public void RaiseDamageRedTeam(int damage) => OnDamageRedTeam?.Invoke(damage);
    public void RaiseDamageBlueTeam(int damage) => OnDamageBlueTeam?.Invoke(damage);

    public Action<int> OnRedTeamHealthChanged;
    public Action<int> OnBlueTeamHealthChanged;
    public Action<int, PlayerRef> OnPlayerHealthChanged;
    public Action OnMatchEvaluation;

    public void RaiseRedTeamHealthChanged(int newHealth)
    {
        OnRedTeamHealthChanged?.Invoke(newHealth);
        if (newHealth <= 0) OnMatchEvaluation?.Invoke();
    }

    public void RaiseBlueTeamHealthChanged(int newHealth)
    {
        OnBlueTeamHealthChanged?.Invoke(newHealth);
        if (newHealth <= 0) OnMatchEvaluation?.Invoke();
    }

    public void RaisePlayerHealthChanged(int newHealth, PlayerRef player)
    {
        OnPlayerHealthChanged?.Invoke(newHealth, player);
        //   if (newHealth <= 0) OnMatchEvaluation?.Invoke();
    }

    public Func<int> OnRedTeamHealthRequest;
    public Func<int> OnBlueTeamHealthRequest;

    public int RequestRedTeamHealth() => OnRedTeamHealthRequest();
    public int RequestBlueTeamHealth() => OnBlueTeamHealthRequest();
}