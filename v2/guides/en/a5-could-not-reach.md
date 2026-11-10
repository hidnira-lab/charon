# A5 · When Charon Says Could Not Reach

When a **first connect** fails any of the four verification checks, Charon stops immediately in `Could not reach` instead of looping retries in the background. Automatic retries apply only after a session has already reached `Connected` (`SM3`).

## What to Check First

1. **Check the server status**: Confirm your VPS is running and `systemctl status xray` shows `active (running)`.
2. **Test the TCP port**: Verify that your server firewall and cloud security group allow inbound TCP traffic on your configured port.
3. **Check Reality parameters**: If the failure card says `The server answered, but the Reality handshake failed`, compare `pbk`, `sid`, and `sni` against your server config ([A4](a4-reality-keys-and-sni.md)).
4. **Check your DNS setting**: If the fourth check (`DNS is not going through the tunnel`) failed and you set a custom DNS address in `Settings > Network`, switch DNS back to `Default` and try again.
5. **Try a backup server**: If you have more than one server configured, click `Choose another server` on the Home banner to switch immediately.
