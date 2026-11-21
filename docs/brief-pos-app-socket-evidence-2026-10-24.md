# Brief — POS mobile app: prove socket behaviour with evidence (E41)

Date: 2026-10-24 · From: Abhishek Jain (owner) · To: POS app team (Gyan, Piyush)
Related: `brief-pos-app-socket-claims-2026-10-24.md` (C1–C11), the app team's investigation of 24 Oct, `claude/infra/publish-js-hotfix-2026-10-24.md`
Server evidence source: CloudWatch `/aws/ec2/pm2/prod` (socket server). Times are IST.

---

## 1. Why this brief

There are now three statements about the app socket, and they don't agree:

| Source | Statement |
|---|---|
| App team, verbal | "As soon as we log in, the socket is always connected, unless the user logs out or kills the app." |
| App team, written investigation (24 Oct) | Every screen creates its own socket in `initState` and disposes it in `dispose()`. `dispose()` sets `skipReconnect`. There is no resume handling. Five screens open a `forceNew` socket on disconnect without joining. A 401/403 disposes `homeSocket`. |
| Server log (24 Oct, 13:33–14:33, app clients only) | 555 app connections opened for about 220 devices online at once. 511 closed within the hour. **Median lifetime 45 s.** 451 closed from the device side (`transport close`). 13 closed by the app calling `disconnect()`. One device at restaurant 742 connected **50 times in one hour**; one at 839, **38 times**. |

All three can't be true. This brief asks the app team to **produce evidence** for what the app actually does on a real device, using logs that can be matched one-to-one with the server log. The aim is to agree on the facts, not to assign blame.

---

## 2. Instrumentation (required before any test)

Add one log line for each of the following, in a debug build that can also be given to one or two real restaurants.

| Event | When to log it | Fields |
|---|---|---|
| `SOCKET_CREATE` | every call that creates a socket (`IO.io(…)`, `io(…)`, any `forceNew`) | time, file/function, screen, restaurant_id, role |
| `SOCKET_CONNECT` | `onConnect` | time, **socket.id**, screen, restaurant_id |
| `SOCKET_JOIN` | every `join_restaurant` emit | time, socket.id, room, screen |
| `SOCKET_DISCONNECT` | `onDisconnect` | time, socket.id, **reason**, screen |
| `SOCKET_DISPOSE` / `SOCKET_CLOSE` | every call to `dispose()`, `disconnect()`, `close()` on a socket | time, socket.id, **file/function that called it**, screen |
| `SOCKET_RECONNECT_ATTEMPT` / `SOCKET_RECONNECT` | client reconnect events | time, socket.id, attempt |
| `SCREEN` | every route push, pop and replace (`Get.to`, `Get.off*`, back) | time, from → to |
| `LIFECYCLE` | app paused, resumed, inactive (add a temporary `WidgetsBindingObserver` if needed) | time, state, socket connected yes/no |
| `PUSH_RECEIVED` | Firebase message received | time, type, order_id, and what the handler did (refresh? reconnect?) |
| `ORDER_EVENT` | every socket order event received (`new_order_<id>` etc.) | time, socket.id, event, order_id |

**`socket.id` is mandatory.** The server logs the same id, so each app log line can be matched exactly to the server's connect, join and disconnect lines and to every order event the server sent.

Also send the **app version** in the handshake (`auth: { app_version, restaurant_id }`), or at least log it at the top of the log file.

---

## 3. Tests to run

Use **one phone, one restaurant, one build, one network** per test. For each test, record the **start time, end time, restaurant ID, device model, network (Wi-Fi or mobile data) and role**. Export the app log after each test.

| # | Test | Steps | What the claim predicts | What to capture |
|---|---|---|---|---|
| T1 | Idle on POS home | Log in, stay on POS home, don't touch the phone for 15 min. Keep the screen on. | 1 connection, no disconnects | All socket lines |
| T2 | Normal order flow | Log in. Take an order, send KOT, settle the bill, mark paid. Repeat 3 times over 10 min. | 1 connection | All socket and SCREEN lines |
| T3 | Screen navigation | From POS home, open each of: running orders, table view, KDS (if role allows), Swiggy/Zomato list, date-wise orders, delivery, settings. Return to POS home after each. | 1 connection | SCREEN + every SOCKET_CREATE/DISPOSE |
| T4 | Screen off / background | On POS home, let the screen sleep for 5 min, then wake it. Then send the app to the background for 5 min and return. | 1 connection, events still received | LIFECYCLE + socket lines, and whether orders placed during sleep appear without a refresh |
| T5 | Network blip | Turn airplane mode on for 10 s, then off. Repeat 3 times. | Automatic reconnect + rejoin within seconds | RECONNECT + JOIN lines |
| T6 | Account / role switch | Log out, log in as another role (Manager → Owner → Waiter), then place an order. | 1 new connection per login, which joins | SOCKET_CREATE/JOIN per login, any 401 |
| T7 | Waiter home / tablet home | Log in with a role or device that lands on waiter home or tablet home. Place an order from another device. | Socket connected and joined | Whether any socket is created at all |
| T8 | Receive while idle | Phone A idle on POS home (T1 state). Phone B or web places 3 orders, 2 min apart. | Phone A shows each order within 2 s, without a refresh | ORDER_EVENT on A, with timestamps |
| T9 | Push as backup | Put phone A in the background, or on a screen without a joined socket. Place an order from phone B. | (Question) Does the push wake the app, reconnect and refresh? | PUSH_RECEIVED + what happened after |

T8 is the test that matters most to restaurants: **does an idle phone receive an order placed elsewhere, instantly?**

---

## 4. Real devices to look at

These are the heaviest reconnecting devices on the server in the last hour (13:33–14:33). With the restaurant's permission, CS can find out which device and screen they are, or the debug build can be installed there:

| Restaurant | IP seen by server | App connections in 1 hour |
|---|---|---|
| 742 | 36.255.235.28 | 50 |
| 839 | 122.162.151.223 | 38 |
| 456 | 103.129.111.36 | 24 |
| 594 | 59.96.35.210 | 16 |
| 844 | 36.255.235.24 | 14 |
| 541 | 103.129.108.54 | 13 |

Also check the restaurants that keep missing events at peak: **682, 486, 563, 795, 631**. Ask which screen and role their main device stays on.

---

## 5. How results will be verified

For each test, send:

1. the exported app log
2. the start/end time, restaurant ID and device

Claude pulls the server log for the same window and returns a table per test:

- **connections opened**, with socket ids
- **lifetime** of each connection and **why it ended** (server-side reason)
- **joins**: which socket joined which room, and when
- **order events** sent to that restaurant during the test, and how many devices were in the room for each

Because both sides log `socket.id`, any disagreement between the app log and the server log shows up immediately and can be investigated on that exact line.

---

## 6. Deliverables

1. **The results table for T1–T9:**

   | Test | Connections | Expected | Disconnect reasons | Join on each connect? | Order received instantly? | Code path responsible |
   |---|---|---|---|---|---|---|

2. **A list of every place the app creates, disposes or disconnects a socket**: file, function, trigger. This should match the investigation, extended with anything found during the tests.
3. **The intended design, in one sentence**, signed off by the app lead. Either:
   - (a) one connection for the whole session, reconnecting on resume and on network change, or
   - (b) connect only when needed, relying on the push to wake and refresh.

   The server metrics will be measured against whichever is chosen.
4. **The fix plan and ETA** for any test that fails. The same-day patch from the investigation follow-up covers most of it:
   - reuse the socket
   - don't dispose it on screen change
   - remove the `forceNew` re-creation on disconnect
   - reconnect and refetch on resume
   - send `auth` on connect

---

## 7. Acceptance

The claim "connected from login until logout" is accepted when:

- **T1, T2, T3 and T4** each show **one** server-side connection for the whole test on the server log.
- **T8** shows every order arriving on the idle phone within 2 seconds.

After the fix ships, the same server metric is checked on a normal service day:

- the median app connection lifetime moves from **~45 s** to **hours**
- connections per device per hour go from **10–50** to **about 1**
- order events sent to an empty restaurant room during peak drop from **~350/hour** to **near zero**
