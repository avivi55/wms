if (SERVER)then


for k,v in pairs(player.GetAll())do
    print(v, v:Alive())
end

http.Post("https://discord.com/api/webhooks/1073583274963771462/YYbsKm8N6_e9cB3sI7DmiTdJHmTPVLnsmOUGiJorWew_tr-rll30EP8nrzaQlYI_ZlWp", {
	"content"= "ta mère",
	-- "embeds"= nil,
	"username"= "oups",
	"avatar_url"= "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Gull_portrait_ca_usa.jpg/1280px-Gull_portrait_ca_usa.jpg",
	"attachments"= []
})

end