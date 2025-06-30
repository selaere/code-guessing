channel = int(input())

import discord
client = discord.Client(intents=discord.Intents.default())

@client.event
async def on_ready():
    await client.get_channel(channel).send("https://weatherornot.bandcamp.com/track/blanket")

client.run(input())