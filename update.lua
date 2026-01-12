-- update.lua
-- URL brute de ton script principal
local url = "https://raw.githubusercontent.com/xavierfrhf-fr/cc-tweaked-particle_accelerator/main/main.lua"

-- nom du fichier local à remplacer
local localFile = "main.lua"

print("Téléchargement de la dernière version depuis GitHub dans 3 secondes...")
sleep(3)

-- tentative de requête HTTP
local success, response = pcall(http.get, url)

if not success or response == nil then
  printError("Erreur HTTP : impossible de télécharger le fichier (http disabled ou URL incorrecte)")
  return
end

-- lire tout le contenu
local content = response.readAll()
response.close()

if not content or #content == 0 then
  printError("Le contenu téléchargé est vide !")
  return
end

-- sauvegarde dans le fichier local
local f = fs.open(localFile, "w")
if not f then
  printError("Impossible d'ouvrir le fichier local pour écriture.")
  return
end

f.write(content)
f.close()

print("Mise à jour terminée ! Le fichier '" .. localFile .. "' a été remplacé.")
