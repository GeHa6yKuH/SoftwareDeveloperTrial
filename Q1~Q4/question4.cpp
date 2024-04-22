#include <memory>
// assuming we can use the smart pointers to prevent potential memory leaks caused by
// creating a new raw pointer using "new" keyword without appropriate "delete" + "pointer"
// invocation. This problem can also be solved by adding "delete player" every time we assume
// the new pointer was created and goes out of addItemToPlayer() scope, however this makes
// code unscalable and inconvenient to use. For this reason I decided to use uniwue_ptr
// of standard cpp library (namespace std) instead, which handles memory for me.

void Game::addItemToPlayer(const std::string& recipient, uint16_t itemId)
{
	Player* player = g_game.getPlayerByName(recipient);
	// creating of unique_ptr to handle memory instead of handling raw pointers with "delete"
	// assuming Player is being successfully created if nullptr passed to constructor
	std::unique_ptr<Player> newPlayer;

	if (!player) {
		newPlayer = std::make_unique<Player>(nullptr);
		// getting raw pointer throuh .get() function
		if (!IOLoginData::loadPlayerByName(newPlayer.get(), recipient)) {
			return;
		}
		// reassigning player pointer to a new created player
		player = newPlayer.get();
	}

	Item* item = Item::CreateItem(itemId);
	if (!item) {
		return;
	}

	g_game.internalAddItem(player->getInbox(), item, INDEX_WHEREEVER, FLAG_NOLIMIT);

	if (player->isOffline()) {
		IOLoginData::savePlayer(player);
	}
}