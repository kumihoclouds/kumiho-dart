Authentication
==============

Token Sources
-------------

Kumiho authenticates with a Bearer token attached to every gRPC call. The client loads the token in the following order:

1. A token provided directly to ``KumihoClient`` via the ``token`` argument.
2. The ``KUMIHO_AUTH_TOKEN`` environment variable.
3. Credentials cached by ``kumiho-cli login`` at ``~/.kumiho/kumiho_authentication.json``.

You can disable automatic loading by setting ``autoLoadToken: false`` when constructing ``KumihoClientBase``.

Environment Variables
---------------------

The SDK recognizes several variables for authentication behaviour:

===============================  ================================================================
Variable                         Description
===============================  ================================================================
``KUMIHO_AUTH_TOKEN``            Primary token, overrides anything stored in the credentials file.
``KUMIHO_ENABLE_AUTO_REFRESH``   When ``true``, refreshes expiring tokens using cached credentials.
``KUMIHO_USE_CONTROL_PLANE_TOKEN``  Prefer the control-plane token if present in cached credentials.
``KUMIHO_AUTH_TOKEN_GRACE_SECONDS`` Grace period before expiry that triggers refresh (default ``300``).
===============================  ================================================================

Token Refresh
-------------

Automatic refresh is opt-in via ``KUMIHO_ENABLE_AUTO_REFRESH``. When enabled, the client loads cached credentials, refreshes tokens when they approach expiry, and updates the Bearer token used in subsequent requests. You can also call ``forceRefreshToken`` to force a refresh attempt regardless of expiry state.

Manual Token Updates
--------------------

Set ``client.token`` at runtime to replace the active Bearer token. This is useful when rotating tokens or swapping between user sessions in long-lived applications.
