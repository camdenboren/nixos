import asyncio
import sys

from dbus_next import BusType, Message, MessageType
from dbus_next.aio import MessageBus


async def main():
    device = "/dev_" + sys.argv[1].upper().replace(":", "_")
    command = sys.argv[2:]
    tasks = set()
    bus = await MessageBus(bus_type=BusType.SYSTEM).connect()

    async def launch():
        print(f"{sys.argv[1]} connected; starting Steam", flush=True)
        try:
            process = await asyncio.create_subprocess_exec(*command)
            if await process.wait() != 0:
                print("Failed to start Steam service", file=sys.stderr, flush=True)
        except OSError as error:
            print(f"Failed to start Steam service: {error}", file=sys.stderr, flush=True)

    def on_message(message):
        if (
            message.message_type != MessageType.SIGNAL
            or message.interface != "org.freedesktop.DBus.Properties"
            or message.member != "PropertiesChanged"
            or not message.path
            or not message.path.startswith("/org/bluez/")
            or not message.path.endswith(device)
            or message.signature != "sa{sv}as"
            or message.body[0] != "org.bluez.Device1"
        ):
            return
        connected = message.body[1].get("Connected")
        if connected is not None and connected.value is True:
            task = asyncio.create_task(launch())
            tasks.add(task)
            task.add_done_callback(tasks.discard)

    bus.add_message_handler(on_message)
    reply = await bus.call(
        Message(
            destination="org.freedesktop.DBus",
            path="/org/freedesktop/DBus",
            interface="org.freedesktop.DBus",
            member="AddMatch",
            signature="s",
            body=[
                "type='signal',sender='org.bluez',"
                "interface='org.freedesktop.DBus.Properties',"
                "member='PropertiesChanged',arg0='org.bluez.Device1'"
            ],
        )
    )
    if reply.message_type == MessageType.ERROR:
        raise RuntimeError(f"Cannot subscribe to Bluetooth events: {reply.body}")
    print(f"Listening for {sys.argv[1]}", flush=True)
    await bus.wait_for_disconnect()


if __name__ == "__main__":
    asyncio.run(main())
