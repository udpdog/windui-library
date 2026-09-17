# WindUI sur Vercel

Projet sans dépendances, prêt à importer dans Vercel. Le fichier original
`scripts/WindUI.lua` reste inchangé.

## Comportement

- `/WindUI.lua` et `/api/script` : Lua pour les requêtes GET dont le User-Agent
  commence par `Roblox/` ou `Roblox ` (ou vaut `Roblox`).
- Navigation dans un navigateur, autres clients, autres méthodes et autres
  chemins : statut HTTP **404** et texte `404: Not Found`.
- Pas de cache navigateur/CDN. Aucun Lua dans le dossier statique `public/`.

Ce filtre masque le script lors d'une visite classique. **Il ne protège pas le
code source contre sa récupération** : le User-Agent est falsifiable et toute
personne capable de télécharger le Lua peut le conserver. Aucun secret ne doit
être placé dans du Lua distribué aux clients. Une logique réellement confidentielle
doit rester sur un serveur. Le script fourni est la bibliothèque WindUI ; son
chargement renvoie un objet et ne crée pas, à lui seul, une fenêtre.

## Déploiement

1. Mets ce projet dans un dépôt Git **privé**, puis importe-le dans Vercel.
2. Choisis le framework **Other** et la racine de ce dossier.
   `vercel.json` définit la commande de build et le dossier de sortie.
3. Déploie, puis récupère le domaine de production `https://TON-PROJET.vercel.app`.
   Le loader doit être accessible sans connexion Vercel pour fonctionner.

Alternative depuis PowerShell, après connexion à ton compte :

```powershell
npx.cmd vercel login
npx.cmd vercel --prod
```

Configuration basée sur la [documentation officielle Vercel](https://vercel.com/docs/project-configuration/vercel-json)
et les [fonctions Node.js](https://vercel.com/docs/functions/runtimes/node-js/advanced-node-configuration).

## Chargement

Remplace le domaine par celui de ton déploiement :

```lua
local WindUI = loadstring(game:HttpGet("https://TON-PROJET.vercel.app/WindUI.lua"))()
-- Utilise ensuite WindUI pour créer ton interface.
```

Cet exemple suppose un environnement qui fournit `game:HttpGet` et `loadstring`.
Le filtre attend un User-Agent Roblox ; si ton client en utilise un autre, il
recevra aussi une 404. L'exécution dans Roblox n'a pas été testée ici.

Pour mettre à jour la bibliothèque, remplace `scripts/WindUI.lua`, puis redéploie.
Les attributions présentes dans le fichier sont conservées.

## Vérification locale

```powershell
npm.cmd test
npm.cmd run dev
```

Ouvre `http://127.0.0.1:3000/WindUI.lua` : le navigateur reçoit une 404.
Les tests vérifient aussi la réponse Lua octet par octet avec une requête simulant
Roblox, les chemins interdits, les méthodes et l'absence de cache. Ils ne remplacent
pas une vérification du déploiement Vercel et du client Roblox réel.
