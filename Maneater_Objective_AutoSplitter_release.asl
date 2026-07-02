state("Maneater-Win64-Shipping", "Epic")
{
    byte moviePlayerLoading: "Maneater-Win64-Shipping.exe", 0x04AC4600, 0xA8;
}

state("Maneater-Win64-Shipping", "Steam")
{
    byte moviePlayerLoading: "Maneater-Win64-Shipping.exe", 0x04AC4600, 0xA8;
}

startup
{
    settings.Add("objective_splits", true, "Objective / Quest Splits");
    settings.Add("splits_story_state", true, "Story / EP Clear Splits");
    settings.Add("splits_player_state", true, "Player State / Level, XP");
    settings.Add("splits_player_levels", true, "Player Levels 1-40", "splits_player_state");
    settings.Add("splits_bounty_state", true, "Player / Bounty");
    settings.Add("splits_infamy_ranks", true, "Base Game Infamy Ranks 1-10", "splits_bounty_state");
    settings.Add("splits_dlc_infamy_ranks", true, "DLC Infamy Ranks 1-5", "splits_bounty_state");

    vars.targetGuids = new Dictionary<string, uint[]>();
    vars.targetNames = new Dictionary<string, string>();
    vars.targetOrder = new List<string>();
    vars.targetNameLabels = new Dictionary<string, string>();
    vars.targetLevelSplits = new Dictionary<string, int>();
    vars.targetXPSplits = new Dictionary<string, int>();
    vars.targetInfamySplits = new Dictionary<string, int>();
    vars.targetDlcInfamySplits = new Dictionary<string, int>();
    vars.targetStorySplits = new Dictionary<string, int>();
    vars.pendingStorySplits = new HashSet<string>();
    vars.pendingObjectiveSplits = new HashSet<string>();
    vars.pendingPlayerLevelSplits = new HashSet<string>();
    vars.pendingPlayerXPSplits = new HashSet<string>();
    vars.pendingInfamySplits = new HashSet<string>();
    vars.pendingDlcInfamySplits = new HashSet<string>();

    for (int level = 1; level <= 40; level++)
    {
        string id = "split_level_" + level;
        settings.Add(id, false, "Player Level " + level, "splits_player_levels");
        vars.targetLevelSplits[id] = level;
    }

    for (int rank = 1; rank <= 10; rank++)
    {
        string id = "split_infamy_" + rank;
        settings.Add(id, false, "Infamy Rank " + rank, "splits_infamy_ranks");
        vars.targetInfamySplits[id] = rank;
    }

    for (int rank = 1; rank <= 5; rank++)
    {
        string id = "split_dlc_infamy_" + rank;
        settings.Add(id, false, "DLC Infamy Rank " + rank, "splits_dlc_infamy_ranks");
        vars.targetDlcInfamySplits[id] = rank;
    }

    for (int ep = 1; ep <= 10; ep++)
    {
        string id = "split_ep_" + ep + "_clear";
        settings.Add(id, false, "EP " + ep + " Clear: ActiveStoryIndex " + ep + " -> " + (ep + 1), "splits_story_state");
        vars.targetStorySplits[id] = ep + 1;
    }

    vars.MakeGuidKey = (Func<uint, uint, uint, uint, string>)((a, b, c, d) =>
        a.ToString("X8") + "-" +
        b.ToString("X8") + "-" +
        c.ToString("X8") + "-" +
        d.ToString("X8")
    );

    vars.MakeNameKey = (Func<string, string, string>)((name, className) =>
        name + "|" + className
    );


    vars.AddObjectiveSplit = (Action<string, bool, string, uint, uint, uint, uint>)((id, enabled, label, a, b, c, d) =>
    {
        settings.Add(id, enabled, label, "objective_splits");
        vars.targetGuids[id] = new uint[] { a, b, c, d };
        vars.targetOrder.Add(id);
    });

    vars.AddPlayerXPSplit = (Action<string, bool, string, int>)((id, enabled, label, xp) =>
    {
        settings.Add(id, enabled, label, "splits_player_state");
        vars.targetXPSplits[id] = xp;
    });

    vars.hadValidObjectiveRead = false;
    vars.hadValidStoryStateRead = false;
    vars.hasObjectiveBaseline = false;
    vars.hasStoryStateBaseline = false;
    vars.hadValidPlayerStateRead = false;
    vars.hasPlayerStateBaseline = false;
    vars.canSplitStoryStateThisFrame = false;
    vars.canSplitPlayerStateThisFrame = false;
    vars.canLevelSplit = false;
    vars.isGameplayWorld = false;
    vars.isNonGameplayWorld = true;
    vars.readIsGameplayWorld = false;
    vars.readIsNonGameplayWorld = true;
    vars.gameplayWorldName = "";
    vars.readGameplayWorldName = "";
    vars.gameplayWorldPtr = IntPtr.Zero;
    vars.readGameplayWorldPtr = IntPtr.Zero;
    vars.wasGameplayWorld = false;
    vars.lastLoggedGameplayWorldState = "";
    vars.lastLoggedDebugSettings = "";
    vars.lastLoggedUpdatePath = "";
    vars.debugUpdatePathFrameCounter = 0;
    vars.playerStateBaselineDelayFrames = 1;
    vars.tutorialObjectiveFound = false;
    vars.tutorialComplete = false;
    vars.pendingLevel1SplitOnTutorialComplete = false;
    vars.hadStoryIndexBeforeLoad = false;
    vars.storyIndexBeforeLoad = 0;
    vars.storyConditionsBeforeLoad = 0;
    vars.tutorialStateF0 = -1;
    vars.tutorialType79 = -1;
    vars.tutorialFlagF1 = -1;
    vars.debugTutorialFrameCounter = 0;
    vars.lastLoggedTutorialState = "";
    vars.hadValidBountyStateRead = false;
    vars.hasBountyStateBaseline = false;
    vars.canSplitBountyStateThisFrame = false;
    vars.suppressSplitThisUpdate = false;
    vars.wasLoading = false;
    vars.justFinishedLoadingFrames = 0;
    vars.lastLoggedCompletedNum = -1;
    vars.lastLoggedGuidDump = "";
    vars.debugObjectiveFrameCounter = 0;
    vars.debugStoryFrameCounter = 0;
    vars.lastLoggedStoryState = "";
    vars.previousCompletedObjectivesNum = 0;
    vars.lastCompletedObjectiveName = "";
    vars.lastCompletedObjectiveGuid = "";
    vars.currentCompletedObjectiveDebugRows = new List<string>();
    vars.lastLoggedPlayerState = "";
    vars.lastLoggedBountyState = "";
    vars.lastLoggedPointerIdentity = "";
    vars.debugBountyFrameCounter = 0;
    vars.debugPointerIdentityFrameCounter = 0;

    settings.Add("region_crawfish_bay", true, "Crawfish Bay", "objective_splits");
    settings.Add("obj_name_terrorizecrawfish_bay_obj0", false, "Crawfish Bay - Terror Of The Bay / Kill the beachgoers", "region_crawfish_bay");
    vars.targetNames.Add("obj_name_terrorizecrawfish_bay_obj0", "ME_PlayerObjectiveTerrorizeCrawfish Bay_Obj0|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizecrawfish_bay_obj0", "ME_PlayerObjectiveTerrorizeCrawfish Bay_Obj0");
    settings.Add("obj_name_nutrientcachecrawfish_bay_obj1", false, "Crawfish Bay - Crawfish Bay Nutrient Caches / Collect all Caches", "region_crawfish_bay");
    vars.targetNames.Add("obj_name_nutrientcachecrawfish_bay_obj1", "ME_PlayerObjectiveNutrientCacheCrawfish Bay_Obj1|ME_PlayerObjectiveNutrientCache");
    vars.targetNameLabels.Add("obj_name_nutrientcachecrawfish_bay_obj1", "ME_PlayerObjectiveNutrientCacheCrawfish Bay_Obj1");
    settings.Add("obj_name_collectablecrawfish_bay_obj2", false, "Crawfish Bay - Crawfish Collectibles / Collect all License Plates", "region_crawfish_bay");
    vars.targetNames.Add("obj_name_collectablecrawfish_bay_obj2", "ME_PlayerObjectiveCollectableCrawfish Bay_Obj2|ME_PlayerObjectiveCollectable");
    vars.targetNameLabels.Add("obj_name_collectablecrawfish_bay_obj2", "ME_PlayerObjectiveCollectableCrawfish Bay_Obj2");
    settings.Add("obj_name_gratescrawfish_bay_obj3", false, "Crawfish Bay - Crawfish Bay Grates", "region_crawfish_bay");
    vars.targetNames.Add("obj_name_gratescrawfish_bay_obj3", "ME_PlayerObjectiveGratesCrawfish Bay_Obj3|ME_PlayerObjectiveGrates");
    vars.targetNameLabels.Add("obj_name_gratescrawfish_bay_obj3", "ME_PlayerObjectiveGratesCrawfish Bay_Obj3");
    settings.Add("obj_name_bosscrawfish_bay_obj4", false, "Crawfish Bay - Meet Pete / Confront Scaly Pete", "region_crawfish_bay");
    vars.targetNames.Add("obj_name_bosscrawfish_bay_obj4", "ME_PlayerObjectiveBossCrawfish Bay_Obj4|ME_PlayerObjectiveBoss");
    vars.targetNameLabels.Add("obj_name_bosscrawfish_bay_obj4", "ME_PlayerObjectiveBossCrawfish Bay_Obj4");

    settings.Add("region_fawtick_bayou", true, "Fawtick Bayou", "objective_splits");
    settings.Add("obj_name_destroythrashablefawtick_bayou_obj0", false, "Fawtick Bayou - Pound Of Flesh / Eat Pete's Hand", "region_fawtick_bayou");
    vars.targetNames.Add("obj_name_destroythrashablefawtick_bayou_obj0", "ME_PlayerObjectiveDestroyThrashableFawtick Bayou_Obj0|ME_PlayerObjectiveDestroyThrashable");
    vars.targetNameLabels.Add("obj_name_destroythrashablefawtick_bayou_obj0", "ME_PlayerObjectiveDestroyThrashableFawtick Bayou_Obj0");
    settings.Add("obj_name_grottofawtick_bayou_obj1", false, "Fawtick Bayou - Cradle to the Cave / Visit the Fawtick Bayou grotto", "region_fawtick_bayou");
    vars.targetNames.Add("obj_name_grottofawtick_bayou_obj1", "ME_PlayerObjectiveGrottoFawtick Bayou_Obj1|ME_PlayerObjectiveGrotto");
    vars.targetNameLabels.Add("obj_name_grottofawtick_bayou_obj1", "ME_PlayerObjectiveGrottoFawtick Bayou_Obj1");
    settings.Add("obj_name_me_huntobjectivefawtick_bayou_obj2", false, "Fawtick Bayou - Muskie Business / Destroy the Target", "region_fawtick_bayou");
    vars.targetNames.Add("obj_name_me_huntobjectivefawtick_bayou_obj2", "ME_HuntObjectiveFawtick Bayou_Obj2|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivefawtick_bayou_obj2", "ME_HuntObjectiveFawtick Bayou_Obj2");
    settings.Add("obj_name_me_huntobjectivefawtick_bayou_obj3", false, "Fawtick Bayou - Midwest Zest / Destroy the Target", "region_fawtick_bayou");
    vars.targetNames.Add("obj_name_me_huntobjectivefawtick_bayou_obj3", "ME_HuntObjectiveFawtick Bayou_Obj3|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivefawtick_bayou_obj3", "ME_HuntObjectiveFawtick Bayou_Obj3");
    settings.Add("obj_name_me_huntobjectivefawtick_bayou_obj4", false, "Fawtick Bayou - Bad Day Sunshine / Destroy the Target", "region_fawtick_bayou");
    vars.targetNames.Add("obj_name_me_huntobjectivefawtick_bayou_obj4", "ME_HuntObjectiveFawtick Bayou_Obj4|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivefawtick_bayou_obj4", "ME_HuntObjectiveFawtick Bayou_Obj4");
    settings.Add("obj_name_me_huntobjectivefawtick_bayou_obj5", false, "Fawtick Bayou - What's the Crocodilly, Yo? / Destroy the Target", "region_fawtick_bayou");
    vars.targetNames.Add("obj_name_me_huntobjectivefawtick_bayou_obj5", "ME_HuntObjectiveFawtick Bayou_Obj5|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivefawtick_bayou_obj5", "ME_HuntObjectiveFawtick Bayou_Obj5");
    settings.Add("obj_name_me_huntobjectivefawtick_bayou_obj6", false, "Fawtick Bayou - See You Later, Alligator / Destroy the Target", "region_fawtick_bayou");
    vars.targetNames.Add("obj_name_me_huntobjectivefawtick_bayou_obj6", "ME_HuntObjectiveFawtick Bayou_Obj6|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivefawtick_bayou_obj6", "ME_HuntObjectiveFawtick Bayou_Obj6");
    settings.Add("obj_name_populationcontrolfawtick_bayou_obj7", false, "Fawtick Bayou - Catfish Fever / Kill 10 Catfish", "region_fawtick_bayou");
    vars.targetNames.Add("obj_name_populationcontrolfawtick_bayou_obj7", "ME_PlayerObjectivePopulationControlFawtick Bayou_Obj7|ME_PlayerObjectivePopulationControl");
    vars.targetNameLabels.Add("obj_name_populationcontrolfawtick_bayou_obj7", "ME_PlayerObjectivePopulationControlFawtick Bayou_Obj7");
    settings.Add("obj_name_populationcontrolfawtick_bayou_obj8", false, "Fawtick Bayou - Fiyo on the Bayou  / Kill 10 Catfish", "region_fawtick_bayou");
    vars.targetNames.Add("obj_name_populationcontrolfawtick_bayou_obj8", "ME_PlayerObjectivePopulationControlFawtick Bayou_Obj8|ME_PlayerObjectivePopulationControl");
    vars.targetNameLabels.Add("obj_name_populationcontrolfawtick_bayou_obj8", "ME_PlayerObjectivePopulationControlFawtick Bayou_Obj8");
    settings.Add("obj_name_populationcontrolfawtick_bayou_obj9", false, "Fawtick Bayou - Taking Out the Trash / Kill 10 Catfish", "region_fawtick_bayou");
    vars.targetNames.Add("obj_name_populationcontrolfawtick_bayou_obj9", "ME_PlayerObjectivePopulationControlFawtick Bayou_Obj9|ME_PlayerObjectivePopulationControl");
    vars.targetNameLabels.Add("obj_name_populationcontrolfawtick_bayou_obj9", "ME_PlayerObjectivePopulationControlFawtick Bayou_Obj9");
    settings.Add("obj_name_me_killobjectivefawtick_bayou_obj10", false, "Fawtick Bayou - Whole Lotta Rosie / Kill the Apex", "region_fawtick_bayou");
    vars.targetNames.Add("obj_name_me_killobjectivefawtick_bayou_obj10", "ME_KillObjectiveFawtick Bayou_Obj10|ME_KillObjective");
    vars.targetNameLabels.Add("obj_name_me_killobjectivefawtick_bayou_obj10", "ME_KillObjectiveFawtick Bayou_Obj10");
    settings.Add("obj_name_landmarkfawtick_bayou_obj11", false, "Fawtick Bayou - Fawtick Bayou Landmarks / Discover all Landmarks", "region_fawtick_bayou");
    vars.targetNames.Add("obj_name_landmarkfawtick_bayou_obj11", "ME_PlayerObjectiveLandmarkFawtick Bayou_Obj11|ME_PlayerObjectiveLandmark");
    vars.targetNameLabels.Add("obj_name_landmarkfawtick_bayou_obj11", "ME_PlayerObjectiveLandmarkFawtick Bayou_Obj11");
    settings.Add("obj_name_nutrientcachefawtick_bayou_obj12", false, "Fawtick Bayou - Fawtick Bayou Nutrient Caches / Collect all Caches", "region_fawtick_bayou");
    vars.targetNames.Add("obj_name_nutrientcachefawtick_bayou_obj12", "ME_PlayerObjectiveNutrientCacheFawtick Bayou_Obj12|ME_PlayerObjectiveNutrientCache");
    vars.targetNameLabels.Add("obj_name_nutrientcachefawtick_bayou_obj12", "ME_PlayerObjectiveNutrientCacheFawtick Bayou_Obj12");
    settings.Add("obj_name_collectablefawtick_bayou_obj13", false, "Fawtick Bayou - Bayou Bric-a-Brac / Collect all License Plates", "region_fawtick_bayou");
    vars.targetNames.Add("obj_name_collectablefawtick_bayou_obj13", "ME_PlayerObjectiveCollectableFawtick Bayou_Obj13|ME_PlayerObjectiveCollectable");
    vars.targetNameLabels.Add("obj_name_collectablefawtick_bayou_obj13", "ME_PlayerObjectiveCollectableFawtick Bayou_Obj13");
    settings.Add("obj_name_gratesfawtick_bayou_obj14", false, "Fawtick Bayou - Fawtick Bayou Grates", "region_fawtick_bayou");
    vars.targetNames.Add("obj_name_gratesfawtick_bayou_obj14", "ME_PlayerObjectiveGratesFawtick Bayou_Obj14|ME_PlayerObjectiveGrates");
    vars.targetNameLabels.Add("obj_name_gratesfawtick_bayou_obj14", "ME_PlayerObjectiveGratesFawtick Bayou_Obj14");
    settings.Add("obj_name_med_tinfoilhatfawtick_bayou_obj15", false, "Fawtick Bayou - Fawtick Bayou Quester Collector / Find All Questers", "region_fawtick_bayou");
    vars.targetNames.Add("obj_name_med_tinfoilhatfawtick_bayou_obj15", "MED_PlayerObjective_TinFoilHatFawtick Bayou_Obj15|MED_PlayerObjective_TinFoilHat");
    vars.targetNameLabels.Add("obj_name_med_tinfoilhatfawtick_bayou_obj15", "MED_PlayerObjective_TinFoilHatFawtick Bayou_Obj15");

    settings.Add("region_dead_horse_lake", true, "Dead Horse Lake", "objective_splits");
    settings.Add("obj_name_grottodead_horse_lake_obj0", false, "Dead Horse Lake - Third-Cave Feminism / Visit the Dead Horse Lake grotto", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_grottodead_horse_lake_obj0", "ME_PlayerObjectiveGrottoDead Horse Lake_Obj0|ME_PlayerObjectiveGrotto");
    vars.targetNameLabels.Add("obj_name_grottodead_horse_lake_obj0", "ME_PlayerObjectiveGrottoDead Horse Lake_Obj0");
    settings.Add("obj_name_terrorizedead_horse_lake_obj1", false, "Dead Horse Lake - Joltin' Joe's / Consume 10 Humans", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_terrorizedead_horse_lake_obj1", "ME_PlayerObjectiveTerrorizeDead Horse Lake_Obj1|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizedead_horse_lake_obj1", "ME_PlayerObjectiveTerrorizeDead Horse Lake_Obj1");
    settings.Add("obj_name_terrorizedead_horse_lake_obj2", false, "Dead Horse Lake - Dixie Mafia Disposal Service / Consume 5 Humans", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_terrorizedead_horse_lake_obj2", "ME_PlayerObjectiveTerrorizeDead Horse Lake_Obj2|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizedead_horse_lake_obj2", "ME_PlayerObjectiveTerrorizeDead Horse Lake_Obj2");
    settings.Add("obj_name_terrorizedead_horse_lake_obj3", false, "Dead Horse Lake - Beat a Dead Horse / Consume 10 Humans", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_terrorizedead_horse_lake_obj3", "ME_PlayerObjectiveTerrorizeDead Horse Lake_Obj3|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizedead_horse_lake_obj3", "ME_PlayerObjectiveTerrorizeDead Horse Lake_Obj3");
    settings.Add("obj_name_terrorizedead_horse_lake_obj4", false, "Dead Horse Lake - Birds of Passage / Consume 10 Humans", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_terrorizedead_horse_lake_obj4", "ME_PlayerObjectiveTerrorizeDead Horse Lake_Obj4|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizedead_horse_lake_obj4", "ME_PlayerObjectiveTerrorizeDead Horse Lake_Obj4");
    settings.Add("obj_name_terrorizedead_horse_lake_obj5", false, "Dead Horse Lake - Hungry, Hungry for Hobos / Consume 8 Humans", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_terrorizedead_horse_lake_obj5", "ME_PlayerObjectiveTerrorizeDead Horse Lake_Obj5|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizedead_horse_lake_obj5", "ME_PlayerObjectiveTerrorizeDead Horse Lake_Obj5");
    settings.Add("obj_name_me_huntobjectivedead_horse_lake_obj6", false, "Dead Horse Lake - What a Dump! / Destroy the Target", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_me_huntobjectivedead_horse_lake_obj6", "ME_HuntObjectiveDead Horse Lake_Obj6|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivedead_horse_lake_obj6", "ME_HuntObjectiveDead Horse Lake_Obj6");
    settings.Add("obj_name_me_huntobjectivedead_horse_lake_obj7", false, "Dead Horse Lake - Mouth Like a Sewer / Destroy the Target", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_me_huntobjectivedead_horse_lake_obj7", "ME_HuntObjectiveDead Horse Lake_Obj7|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivedead_horse_lake_obj7", "ME_HuntObjectiveDead Horse Lake_Obj7");
    settings.Add("obj_name_me_huntobjectivedead_horse_lake_obj8", false, "Dead Horse Lake - Bank On It / Destroy the Target", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_me_huntobjectivedead_horse_lake_obj8", "ME_HuntObjectiveDead Horse Lake_Obj8|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivedead_horse_lake_obj8", "ME_HuntObjectiveDead Horse Lake_Obj8");
    settings.Add("obj_name_me_huntobjectivedead_horse_lake_obj9", false, "Dead Horse Lake - Take a Bite Out of Organized Crime / Destroy the Target", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_me_huntobjectivedead_horse_lake_obj9", "ME_HuntObjectiveDead Horse Lake_Obj9|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivedead_horse_lake_obj9", "ME_HuntObjectiveDead Horse Lake_Obj9");
    settings.Add("obj_name_me_huntobjectivedead_horse_lake_obj10", false, "Dead Horse Lake - Nuclear Option / Destroy the Target", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_me_huntobjectivedead_horse_lake_obj10", "ME_HuntObjectiveDead Horse Lake_Obj10|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivedead_horse_lake_obj10", "ME_HuntObjectiveDead Horse Lake_Obj10");
    settings.Add("obj_name_populationcontroldead_horse_lake_obj11", false, "Dead Horse Lake - Radioactive Waste / Kill 10 Groupers", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_populationcontroldead_horse_lake_obj11", "ME_PlayerObjectivePopulationControlDead Horse Lake_Obj11|ME_PlayerObjectivePopulationControl");
    vars.targetNameLabels.Add("obj_name_populationcontroldead_horse_lake_obj11", "ME_PlayerObjectivePopulationControlDead Horse Lake_Obj11");
    settings.Add("obj_name_populationcontroldead_horse_lake_obj12", false, "Dead Horse Lake - Grouper Dynamics / Kill 10 Groupers", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_populationcontroldead_horse_lake_obj12", "ME_PlayerObjectivePopulationControlDead Horse Lake_Obj12|ME_PlayerObjectivePopulationControl");
    vars.targetNameLabels.Add("obj_name_populationcontroldead_horse_lake_obj12", "ME_PlayerObjectivePopulationControlDead Horse Lake_Obj12");
    settings.Add("obj_name_populationcontroldead_horse_lake_obj13", false, "Dead Horse Lake - Up the Junction / Kill 8 Groupers", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_populationcontroldead_horse_lake_obj13", "ME_PlayerObjectivePopulationControlDead Horse Lake_Obj13|ME_PlayerObjectivePopulationControl");
    vars.targetNameLabels.Add("obj_name_populationcontroldead_horse_lake_obj13", "ME_PlayerObjectivePopulationControlDead Horse Lake_Obj13");
    settings.Add("obj_name_me_killobjectivedead_horse_lake_obj14", false, "Dead Horse Lake - Ooh, Barracuda(s) / Kill the Apex", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_me_killobjectivedead_horse_lake_obj14", "ME_KillObjectiveDead Horse Lake_Obj14|ME_KillObjective");
    vars.targetNameLabels.Add("obj_name_me_killobjectivedead_horse_lake_obj14", "ME_KillObjectiveDead Horse Lake_Obj14");
    settings.Add("obj_name_gratesdead_horse_lake_obj15", false, "Dead Horse Lake - Dead Horse Lake Grates", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_gratesdead_horse_lake_obj15", "ME_PlayerObjectiveGratesDead Horse Lake_Obj15|ME_PlayerObjectiveGrates");
    vars.targetNameLabels.Add("obj_name_gratesdead_horse_lake_obj15", "ME_PlayerObjectiveGratesDead Horse Lake_Obj15");
    settings.Add("obj_name_landmarkdead_horse_lake_obj16", false, "Dead Horse Lake - Dead Horse Lake Landmarks / Discover all Landmarks", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_landmarkdead_horse_lake_obj16", "ME_PlayerObjectiveLandmarkDead Horse Lake_Obj16|ME_PlayerObjectiveLandmark");
    vars.targetNameLabels.Add("obj_name_landmarkdead_horse_lake_obj16", "ME_PlayerObjectiveLandmarkDead Horse Lake_Obj16");
    settings.Add("obj_name_nutrientcachedead_horse_lake_obj17", false, "Dead Horse Lake - Dead Horse Lake Nutrient Caches / Collect all Caches", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_nutrientcachedead_horse_lake_obj17", "ME_PlayerObjectiveNutrientCacheDead Horse Lake_Obj17|ME_PlayerObjectiveNutrientCache");
    vars.targetNameLabels.Add("obj_name_nutrientcachedead_horse_lake_obj17", "ME_PlayerObjectiveNutrientCacheDead Horse Lake_Obj17");
    settings.Add("obj_name_collectabledead_horse_lake_obj18", false, "Dead Horse Lake - Dead Horse Heirlooms / Collect all License Plates", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_collectabledead_horse_lake_obj18", "ME_PlayerObjectiveCollectableDead Horse Lake_Obj18|ME_PlayerObjectiveCollectable");
    vars.targetNameLabels.Add("obj_name_collectabledead_horse_lake_obj18", "ME_PlayerObjectiveCollectableDead Horse Lake_Obj18");
    settings.Add("obj_name_cutscenedead_horse_lake_obj19", false, "Dead Horse Lake - Like Father, Unlike Son / Check in on Pete", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_cutscenedead_horse_lake_obj19", "ME_PlayerObjectiveCutsceneDead Horse Lake_Obj19|ME_PlayerObjectiveCutscene");
    vars.targetNameLabels.Add("obj_name_cutscenedead_horse_lake_obj19", "ME_PlayerObjectiveCutsceneDead Horse Lake_Obj19");
    settings.Add("obj_name_med_gotodead_horse_lake_obj20", false, "Dead Horse Lake - In Search Of... / Investigate", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_med_gotodead_horse_lake_obj20", "MED_PlayerObjective_GoToDead Horse Lake_Obj20|MED_PlayerObjective_GoTo");
    vars.targetNameLabels.Add("obj_name_med_gotodead_horse_lake_obj20", "MED_PlayerObjective_GoToDead Horse Lake_Obj20");
    settings.Add("obj_name_med_failuretocommunicatedead_horse_lake_obj21", false, "Dead Horse Lake - Sonar and Yet So Far  / Destroy the Sonar Beacon!", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_med_failuretocommunicatedead_horse_lake_obj21", "MED_PlayerObjective_FailureToCommunicateDead Horse Lake_Obj21|MED_PlayerObjective_FailureToCommunicate");
    vars.targetNameLabels.Add("obj_name_med_failuretocommunicatedead_horse_lake_obj21", "MED_PlayerObjective_FailureToCommunicateDead Horse Lake_Obj21");
    settings.Add("obj_name_med_gotodead_horse_lake_obj22", false, "Dead Horse Lake - Pipe Down / Investigate", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_med_gotodead_horse_lake_obj22", "MED_PlayerObjective_GoToDead Horse Lake_Obj22|MED_PlayerObjective_GoTo");
    vars.targetNameLabels.Add("obj_name_med_gotodead_horse_lake_obj22", "MED_PlayerObjective_GoToDead Horse Lake_Obj22");
    settings.Add("obj_name_me_huntobjectivedead_horse_lake_obj23", false, "Dead Horse Lake - A \"Current\" Affair / Destroy the Target!", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_me_huntobjectivedead_horse_lake_obj23", "ME_HuntObjectiveDead Horse Lake_Obj23|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivedead_horse_lake_obj23", "ME_HuntObjectiveDead Horse Lake_Obj23");
    settings.Add("obj_name_me_huntobjectivedead_horse_lake_obj24", false, "Dead Horse Lake - Shipkicker / Destroy the Target!", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_me_huntobjectivedead_horse_lake_obj24", "ME_HuntObjectiveDead Horse Lake_Obj24|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivedead_horse_lake_obj24", "ME_HuntObjectiveDead Horse Lake_Obj24");
    settings.Add("obj_name_terrorizedead_horse_lake_obj25", false, "Dead Horse Lake - Beach Slap / Consume 10 Sailors", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_terrorizedead_horse_lake_obj25", "ME_PlayerObjectiveTerrorizeDead Horse Lake_Obj25|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizedead_horse_lake_obj25", "ME_PlayerObjectiveTerrorizeDead Horse Lake_Obj25");
    settings.Add("obj_name_terrorizedead_horse_lake_obj26", false, "Dead Horse Lake - Looking for Sailors / Consume 10 Sailors", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_terrorizedead_horse_lake_obj26", "ME_PlayerObjectiveTerrorizeDead Horse Lake_Obj26|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizedead_horse_lake_obj26", "ME_PlayerObjectiveTerrorizeDead Horse Lake_Obj26");
    settings.Add("obj_name_med_timetrialdead_horse_lake_obj27", false, "Dead Horse Lake - Time Trial: Luna-Sea / Swim through the rings", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_med_timetrialdead_horse_lake_obj27", "MED_PlayerObjectiveTimeTrialDead Horse Lake_Obj27|MED_PlayerObjectiveTimeTrial");
    vars.targetNameLabels.Add("obj_name_med_timetrialdead_horse_lake_obj27", "MED_PlayerObjectiveTimeTrialDead Horse Lake_Obj27");
    settings.Add("obj_name_med_timetrialdead_horse_lake_obj28", false, "Dead Horse Lake - Time Trial: Ocean Blur / Swim through the rings", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_med_timetrialdead_horse_lake_obj28", "MED_PlayerObjectiveTimeTrialDead Horse Lake_Obj28|MED_PlayerObjectiveTimeTrial");
    vars.targetNameLabels.Add("obj_name_med_timetrialdead_horse_lake_obj28", "MED_PlayerObjectiveTimeTrialDead Horse Lake_Obj28");
    settings.Add("obj_name_med_tinfoilhatdead_horse_lake_obj29", false, "Dead Horse Lake - Dead Horse Lake Quester Collector / Find All Questers", "region_dead_horse_lake");
    vars.targetNames.Add("obj_name_med_tinfoilhatdead_horse_lake_obj29", "MED_PlayerObjective_TinFoilHatDead Horse Lake_Obj29|MED_PlayerObjective_TinFoilHat");
    vars.targetNameLabels.Add("obj_name_med_tinfoilhatdead_horse_lake_obj29", "MED_PlayerObjective_TinFoilHatDead Horse Lake_Obj29");

    settings.Add("region_golden_shores", true, "Golden Shores", "objective_splits");
    settings.Add("obj_name_grottogolden_shores_obj0", false, "Golden Shores - Cave New World / Visit the Golden Shores grotto", "region_golden_shores");
    vars.targetNames.Add("obj_name_grottogolden_shores_obj0", "ME_PlayerObjectiveGrottoGolden Shores_Obj0|ME_PlayerObjectiveGrotto");
    vars.targetNameLabels.Add("obj_name_grottogolden_shores_obj0", "ME_PlayerObjectiveGrottoGolden Shores_Obj0");
    settings.Add("obj_name_terrorizegolden_shores_obj1", false, "Golden Shores - Fin Some, Lose Some / Consume 10 Humans", "region_golden_shores");
    vars.targetNames.Add("obj_name_terrorizegolden_shores_obj1", "ME_PlayerObjectiveTerrorizeGolden Shores_Obj1|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizegolden_shores_obj1", "ME_PlayerObjectiveTerrorizeGolden Shores_Obj1");
    settings.Add("obj_name_terrorizegolden_shores_obj2", false, "Golden Shores - In the Rough / Consume 8 Humans", "region_golden_shores");
    vars.targetNames.Add("obj_name_terrorizegolden_shores_obj2", "ME_PlayerObjectiveTerrorizeGolden Shores_Obj2|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizegolden_shores_obj2", "ME_PlayerObjectiveTerrorizeGolden Shores_Obj2");
    settings.Add("obj_name_terrorizegolden_shores_obj3", false, "Golden Shores - Block Buster / Consume 8 Humans", "region_golden_shores");
    vars.targetNames.Add("obj_name_terrorizegolden_shores_obj3", "ME_PlayerObjectiveTerrorizeGolden Shores_Obj3|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizegolden_shores_obj3", "ME_PlayerObjectiveTerrorizeGolden Shores_Obj3");
    settings.Add("obj_name_terrorizegolden_shores_obj4", false, "Golden Shores - Ace in the Hole / Consume 10 Humans", "region_golden_shores");
    vars.targetNames.Add("obj_name_terrorizegolden_shores_obj4", "ME_PlayerObjectiveTerrorizeGolden Shores_Obj4|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizegolden_shores_obj4", "ME_PlayerObjectiveTerrorizeGolden Shores_Obj4");
    settings.Add("obj_name_terrorizegolden_shores_obj5", false, "Golden Shores - Golden Opportunity / Consume 12 Humans", "region_golden_shores");
    vars.targetNames.Add("obj_name_terrorizegolden_shores_obj5", "ME_PlayerObjectiveTerrorizeGolden Shores_Obj5|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizegolden_shores_obj5", "ME_PlayerObjectiveTerrorizeGolden Shores_Obj5");
    settings.Add("obj_name_me_huntobjectivegolden_shores_obj6", false, "Golden Shores - Uh-Oh, Better Get Mako / Destroy the Target", "region_golden_shores");
    vars.targetNames.Add("obj_name_me_huntobjectivegolden_shores_obj6", "ME_HuntObjectiveGolden Shores_Obj6|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivegolden_shores_obj6", "ME_HuntObjectiveGolden Shores_Obj6");
    settings.Add("obj_name_me_huntobjectivegolden_shores_obj7", false, "Golden Shores - I Spit On Your Cave / Destroy the Target", "region_golden_shores");
    vars.targetNames.Add("obj_name_me_huntobjectivegolden_shores_obj7", "ME_HuntObjectiveGolden Shores_Obj7|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivegolden_shores_obj7", "ME_HuntObjectiveGolden Shores_Obj7");
    settings.Add("obj_name_me_huntobjectivegolden_shores_obj8", false, "Golden Shores - Between Two Holes / Destroy the Target", "region_golden_shores");
    vars.targetNames.Add("obj_name_me_huntobjectivegolden_shores_obj8", "ME_HuntObjectiveGolden Shores_Obj8|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivegolden_shores_obj8", "ME_HuntObjectiveGolden Shores_Obj8");
    settings.Add("obj_name_me_huntobjectivegolden_shores_obj9", false, "Golden Shores - Neighborhood Fang Problem / Destroy the Target", "region_golden_shores");
    vars.targetNames.Add("obj_name_me_huntobjectivegolden_shores_obj9", "ME_HuntObjectiveGolden Shores_Obj9|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivegolden_shores_obj9", "ME_HuntObjectiveGolden Shores_Obj9");
    settings.Add("obj_name_me_huntobjectivegolden_shores_obj10", false, "Golden Shores - Prima Sphyraena  / Destroy the Target", "region_golden_shores");
    vars.targetNames.Add("obj_name_me_huntobjectivegolden_shores_obj10", "ME_HuntObjectiveGolden Shores_Obj10|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivegolden_shores_obj10", "ME_HuntObjectiveGolden Shores_Obj10");
    settings.Add("obj_name_populationcontrolgolden_shores_obj11", false, "Golden Shores - The Sport of Kings / Kill 10 Mackerels", "region_golden_shores");
    vars.targetNames.Add("obj_name_populationcontrolgolden_shores_obj11", "ME_PlayerObjectivePopulationControlGolden Shores_Obj11|ME_PlayerObjectivePopulationControl");
    vars.targetNameLabels.Add("obj_name_populationcontrolgolden_shores_obj11", "ME_PlayerObjectivePopulationControlGolden Shores_Obj11");
    settings.Add("obj_name_populationcontrolgolden_shores_obj12", false, "Golden Shores - Big Mack / Kill 10 Mackerels", "region_golden_shores");
    vars.targetNames.Add("obj_name_populationcontrolgolden_shores_obj12", "ME_PlayerObjectivePopulationControlGolden Shores_Obj12|ME_PlayerObjectivePopulationControl");
    vars.targetNameLabels.Add("obj_name_populationcontrolgolden_shores_obj12", "ME_PlayerObjectivePopulationControlGolden Shores_Obj12");
    settings.Add("obj_name_populationcontrolgolden_shores_obj13", false, "Golden Shores - Cave In / Kill 10 Mackerels", "region_golden_shores");
    vars.targetNames.Add("obj_name_populationcontrolgolden_shores_obj13", "ME_PlayerObjectivePopulationControlGolden Shores_Obj13|ME_PlayerObjectivePopulationControl");
    vars.targetNameLabels.Add("obj_name_populationcontrolgolden_shores_obj13", "ME_PlayerObjectivePopulationControlGolden Shores_Obj13");
    settings.Add("obj_name_me_killobjectivegolden_shores_obj14", false, "Golden Shores - Mako War, Not Love / Kill the Apex", "region_golden_shores");
    vars.targetNames.Add("obj_name_me_killobjectivegolden_shores_obj14", "ME_KillObjectiveGolden Shores_Obj14|ME_KillObjective");
    vars.targetNameLabels.Add("obj_name_me_killobjectivegolden_shores_obj14", "ME_KillObjectiveGolden Shores_Obj14");
    settings.Add("obj_name_landmarkgolden_shores_obj15", false, "Golden Shores - Golden Shores Landmarks / Discover all Landmarks", "region_golden_shores");
    vars.targetNames.Add("obj_name_landmarkgolden_shores_obj15", "ME_PlayerObjectiveLandmarkGolden Shores_Obj15|ME_PlayerObjectiveLandmark");
    vars.targetNameLabels.Add("obj_name_landmarkgolden_shores_obj15", "ME_PlayerObjectiveLandmarkGolden Shores_Obj15");
    settings.Add("obj_name_nutrientcachegolden_shores_obj16", false, "Golden Shores - Golden Shores Nutrient Caches / Collect all Caches", "region_golden_shores");
    vars.targetNames.Add("obj_name_nutrientcachegolden_shores_obj16", "ME_PlayerObjectiveNutrientCacheGolden Shores_Obj16|ME_PlayerObjectiveNutrientCache");
    vars.targetNameLabels.Add("obj_name_nutrientcachegolden_shores_obj16", "ME_PlayerObjectiveNutrientCacheGolden Shores_Obj16");
    settings.Add("obj_name_collectablegolden_shores_obj17", false, "Golden Shores - Golden Goods / Collect all License Plates", "region_golden_shores");
    vars.targetNames.Add("obj_name_collectablegolden_shores_obj17", "ME_PlayerObjectiveCollectableGolden Shores_Obj17|ME_PlayerObjectiveCollectable");
    vars.targetNameLabels.Add("obj_name_collectablegolden_shores_obj17", "ME_PlayerObjectiveCollectableGolden Shores_Obj17");
    settings.Add("obj_name_cutscenegolden_shores_obj19", false, "Golden Shores - Family Update / Cruise by the Cajun Queen", "region_golden_shores");
    vars.targetNames.Add("obj_name_cutscenegolden_shores_obj19", "ME_PlayerObjectiveCutsceneGolden Shores_Obj19|ME_PlayerObjectiveCutscene");
    vars.targetNameLabels.Add("obj_name_cutscenegolden_shores_obj19", "ME_PlayerObjectiveCutsceneGolden Shores_Obj19");
    settings.Add("obj_name_med_gotogolden_shores_obj20", false, "Golden Shores - Damage Assessment / Investigate", "region_golden_shores");
    vars.targetNames.Add("obj_name_med_gotogolden_shores_obj20", "MED_PlayerObjective_GoToGolden Shores_Obj20|MED_PlayerObjective_GoTo");
    vars.targetNameLabels.Add("obj_name_med_gotogolden_shores_obj20", "MED_PlayerObjective_GoToGolden Shores_Obj20");
    settings.Add("obj_name_me_huntobjectivegolden_shores_obj21", false, "Golden Shores - Gross Electric Product / Destroy the Target!", "region_golden_shores");
    vars.targetNames.Add("obj_name_me_huntobjectivegolden_shores_obj21", "ME_HuntObjectiveGolden Shores_Obj21|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivegolden_shores_obj21", "ME_HuntObjectiveGolden Shores_Obj21");
    settings.Add("obj_name_terrorizegolden_shores_obj22", false, "Golden Shores - Home Protection Plan / Consume 10 Sailors", "region_golden_shores");
    vars.targetNames.Add("obj_name_terrorizegolden_shores_obj22", "ME_PlayerObjectiveTerrorizeGolden Shores_Obj22|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizegolden_shores_obj22", "ME_PlayerObjectiveTerrorizeGolden Shores_Obj22");
    settings.Add("obj_name_me_huntobjectivegolden_shores_obj23", false, "Golden Shores - White Lightning / Destroy the Target!", "region_golden_shores");
    vars.targetNames.Add("obj_name_me_huntobjectivegolden_shores_obj23", "ME_HuntObjectiveGolden Shores_Obj23|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivegolden_shores_obj23", "ME_HuntObjectiveGolden Shores_Obj23");
    settings.Add("obj_name_me_huntobjectivegolden_shores_obj24", false, "Golden Shores - Ship Stirrer / Destroy the Target!", "region_golden_shores");
    vars.targetNames.Add("obj_name_me_huntobjectivegolden_shores_obj24", "ME_HuntObjectiveGolden Shores_Obj24|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivegolden_shores_obj24", "ME_HuntObjectiveGolden Shores_Obj24");
    settings.Add("obj_name_terrorizegolden_shores_obj25", false, "Golden Shores - Golf Course Maintenance / Consume 10 Sailors", "region_golden_shores");
    vars.targetNames.Add("obj_name_terrorizegolden_shores_obj25", "ME_PlayerObjectiveTerrorizeGolden Shores_Obj25|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizegolden_shores_obj25", "ME_PlayerObjectiveTerrorizeGolden Shores_Obj25");
    settings.Add("obj_name_terrorizegolden_shores_obj26", false, "Golden Shores - It's All Navy / Consume 10 Sailors", "region_golden_shores");
    vars.targetNames.Add("obj_name_terrorizegolden_shores_obj26", "ME_PlayerObjectiveTerrorizeGolden Shores_Obj26|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizegolden_shores_obj26", "ME_PlayerObjectiveTerrorizeGolden Shores_Obj26");
    settings.Add("obj_name_med_timetrialgolden_shores_obj27", false, "Golden Shores - Time Trial: Swim Reaper / Swim through the rings.", "region_golden_shores");
    vars.targetNames.Add("obj_name_med_timetrialgolden_shores_obj27", "MED_PlayerObjectiveTimeTrialGolden Shores_Obj27|MED_PlayerObjectiveTimeTrial");
    vars.targetNameLabels.Add("obj_name_med_timetrialgolden_shores_obj27", "MED_PlayerObjectiveTimeTrialGolden Shores_Obj27");
    settings.Add("obj_name_med_timetrialgolden_shores_obj28", false, "Golden Shores - Time Trial: Water Torture / Swim through the rings.", "region_golden_shores");
    vars.targetNames.Add("obj_name_med_timetrialgolden_shores_obj28", "MED_PlayerObjectiveTimeTrialGolden Shores_Obj28|MED_PlayerObjectiveTimeTrial");
    vars.targetNameLabels.Add("obj_name_med_timetrialgolden_shores_obj28", "MED_PlayerObjectiveTimeTrialGolden Shores_Obj28");
    settings.Add("obj_name_med_tinfoilhatgolden_shores_obj29", false, "Golden Shores - Golden Shores Quester Collector / Find All Questers", "region_golden_shores");
    vars.targetNames.Add("obj_name_med_tinfoilhatgolden_shores_obj29", "MED_PlayerObjective_TinFoilHatGolden Shores_Obj29|MED_PlayerObjective_TinFoilHat");
    vars.targetNameLabels.Add("obj_name_med_tinfoilhatgolden_shores_obj29", "MED_PlayerObjective_TinFoilHatGolden Shores_Obj29");

    settings.Add("region_sapphire_bay", true, "Sapphire Bay", "objective_splits");
    settings.Add("obj_name_grottosapphire_bay_obj0", false, "Sapphire Bay - Shark of Constant Grotto / Visit the Sapphire Bay grotto", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_grottosapphire_bay_obj0", "ME_PlayerObjectiveGrottoSapphire Bay_Obj0|ME_PlayerObjectiveGrotto");
    vars.targetNameLabels.Add("obj_name_grottosapphire_bay_obj0", "ME_PlayerObjectiveGrottoSapphire Bay_Obj0");
    settings.Add("obj_name_terrorizesapphire_bay_obj1", false, "Sapphire Bay - Carnival Sins / Consume 10 Humans", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_terrorizesapphire_bay_obj1", "ME_PlayerObjectiveTerrorizeSapphire Bay_Obj1|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizesapphire_bay_obj1", "ME_PlayerObjectiveTerrorizeSapphire Bay_Obj1");
    settings.Add("obj_name_terrorizesapphire_bay_obj2", false, "Sapphire Bay - Big Mama's House / Consume 10 Humans", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_terrorizesapphire_bay_obj2", "ME_PlayerObjectiveTerrorizeSapphire Bay_Obj2|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizesapphire_bay_obj2", "ME_PlayerObjectiveTerrorizeSapphire Bay_Obj2");
    settings.Add("obj_name_terrorizesapphire_bay_obj3", false, "Sapphire Bay - Payback's a Beach / Consume 15 Humans", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_terrorizesapphire_bay_obj3", "ME_PlayerObjectiveTerrorizeSapphire Bay_Obj3|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizesapphire_bay_obj3", "ME_PlayerObjectiveTerrorizeSapphire Bay_Obj3");
    settings.Add("obj_name_terrorizesapphire_bay_obj4", false, "Sapphire Bay - Come to the Light / Consume 12 Humans", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_terrorizesapphire_bay_obj4", "ME_PlayerObjectiveTerrorizeSapphire Bay_Obj4|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizesapphire_bay_obj4", "ME_PlayerObjectiveTerrorizeSapphire Bay_Obj4");
    settings.Add("obj_name_terrorizesapphire_bay_obj5", false, "Sapphire Bay - Bay for Blood / Consume 10 Humans", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_terrorizesapphire_bay_obj5", "ME_PlayerObjectiveTerrorizeSapphire Bay_Obj5|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizesapphire_bay_obj5", "ME_PlayerObjectiveTerrorizeSapphire Bay_Obj5");
    settings.Add("obj_name_populationcontrolsapphire_bay_obj6", false, "Sapphire Bay - The Parrot Trap / Kill 10 Parrotfish", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_populationcontrolsapphire_bay_obj6", "ME_PlayerObjectivePopulationControlSapphire Bay_Obj6|ME_PlayerObjectivePopulationControl");
    vars.targetNameLabels.Add("obj_name_populationcontrolsapphire_bay_obj6", "ME_PlayerObjectivePopulationControlSapphire Bay_Obj6");
    settings.Add("obj_name_populationcontrolsapphire_bay_obj7", false, "Sapphire Bay - Lighten Up / Kill 10 Parrotfish", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_populationcontrolsapphire_bay_obj7", "ME_PlayerObjectivePopulationControlSapphire Bay_Obj7|ME_PlayerObjectivePopulationControl");
    vars.targetNameLabels.Add("obj_name_populationcontrolsapphire_bay_obj7", "ME_PlayerObjectivePopulationControlSapphire Bay_Obj7");
    settings.Add("obj_name_populationcontrolsapphire_bay_obj8", false, "Sapphire Bay - Cabana Republic / Kill 10 Parrotfish", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_populationcontrolsapphire_bay_obj8", "ME_PlayerObjectivePopulationControlSapphire Bay_Obj8|ME_PlayerObjectivePopulationControl");
    vars.targetNameLabels.Add("obj_name_populationcontrolsapphire_bay_obj8", "ME_PlayerObjectivePopulationControlSapphire Bay_Obj8");
    settings.Add("obj_name_me_huntobjectivesapphire_bay_obj9", false, "Sapphire Bay - Mother Ship / Destroy the Target", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_me_huntobjectivesapphire_bay_obj9", "ME_HuntObjectiveSapphire Bay_Obj9|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivesapphire_bay_obj9", "ME_HuntObjectiveSapphire Bay_Obj9");
    settings.Add("obj_name_me_huntobjectivesapphire_bay_obj10", false, "Sapphire Bay - Treasure Hunt / Destroy the Target", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_me_huntobjectivesapphire_bay_obj10", "ME_HuntObjectiveSapphire Bay_Obj10|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivesapphire_bay_obj10", "ME_HuntObjectiveSapphire Bay_Obj10");
    settings.Add("obj_name_me_huntobjectivesapphire_bay_obj11", false, "Sapphire Bay - Fisherman's Friend / Destroy the Target", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_me_huntobjectivesapphire_bay_obj11", "ME_HuntObjectiveSapphire Bay_Obj11|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivesapphire_bay_obj11", "ME_HuntObjectiveSapphire Bay_Obj11");
    settings.Add("obj_name_me_huntobjectivesapphire_bay_obj12", false, "Sapphire Bay - Hammer It Out / Destroy the Target", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_me_huntobjectivesapphire_bay_obj12", "ME_HuntObjectiveSapphire Bay_Obj12|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivesapphire_bay_obj12", "ME_HuntObjectiveSapphire Bay_Obj12");
    settings.Add("obj_name_me_huntobjectivesapphire_bay_obj13", false, "Sapphire Bay - Marlin of Error / Destroy the Target", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_me_huntobjectivesapphire_bay_obj13", "ME_HuntObjectiveSapphire Bay_Obj13|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivesapphire_bay_obj13", "ME_HuntObjectiveSapphire Bay_Obj13");
    settings.Add("obj_name_landmarksapphire_bay_obj14", false, "Sapphire Bay - Sapphire Bay Landmarks / Discover all Landmarks", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_landmarksapphire_bay_obj14", "ME_PlayerObjectiveLandmarkSapphire Bay_Obj14|ME_PlayerObjectiveLandmark");
    vars.targetNameLabels.Add("obj_name_landmarksapphire_bay_obj14", "ME_PlayerObjectiveLandmarkSapphire Bay_Obj14");
    settings.Add("obj_name_me_killobjectivesapphire_bay_obj15", false, "Sapphire Bay - Put the Hammer Down / Kill the Apex", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_me_killobjectivesapphire_bay_obj15", "ME_KillObjectiveSapphire Bay_Obj15|ME_KillObjective");
    vars.targetNameLabels.Add("obj_name_me_killobjectivesapphire_bay_obj15", "ME_KillObjectiveSapphire Bay_Obj15");
    settings.Add("obj_name_nutrientcachesapphire_bay_obj16", false, "Sapphire Bay - Sapphire Bay Nutrient Caches / Collect all Caches", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_nutrientcachesapphire_bay_obj16", "ME_PlayerObjectiveNutrientCacheSapphire Bay_Obj16|ME_PlayerObjectiveNutrientCache");
    vars.targetNameLabels.Add("obj_name_nutrientcachesapphire_bay_obj16", "ME_PlayerObjectiveNutrientCacheSapphire Bay_Obj16");
    settings.Add("obj_name_collectablesapphire_bay_obj17", false, "Sapphire Bay - Sapphire Souvenirs / Collect all License Plates", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_collectablesapphire_bay_obj17", "ME_PlayerObjectiveCollectableSapphire Bay_Obj17|ME_PlayerObjectiveCollectable");
    vars.targetNameLabels.Add("obj_name_collectablesapphire_bay_obj17", "ME_PlayerObjectiveCollectableSapphire Bay_Obj17");
    settings.Add("obj_name_gratessapphire_bay_obj18", false, "Sapphire Bay - Sapphire Bay Grates", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_gratessapphire_bay_obj18", "ME_PlayerObjectiveGratesSapphire Bay_Obj18|ME_PlayerObjectiveGrates");
    vars.targetNameLabels.Add("obj_name_gratessapphire_bay_obj18", "ME_PlayerObjectiveGratesSapphire Bay_Obj18");
    settings.Add("obj_name_cutscenesapphire_bay_obj19", false, "Sapphire Bay - Personal Project / Have a look at Pete's latest undertaking", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_cutscenesapphire_bay_obj19", "ME_PlayerObjectiveCutsceneSapphire Bay_Obj19|ME_PlayerObjectiveCutscene");
    vars.targetNameLabels.Add("obj_name_cutscenesapphire_bay_obj19", "ME_PlayerObjectiveCutsceneSapphire Bay_Obj19");
    settings.Add("obj_name_bosssapphire_bay_obj20", false, "Sapphire Bay - Pete: The Revenge / Challenge Pete and Kyle", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_bosssapphire_bay_obj20", "ME_PlayerObjectiveBossSapphire Bay_Obj20|ME_PlayerObjectiveBoss");
    vars.targetNameLabels.Add("obj_name_bosssapphire_bay_obj20", "ME_PlayerObjectiveBossSapphire Bay_Obj20");
    settings.Add("obj_name_med_failuretocommunicatesapphire_bay_obj21", false, "Sapphire Bay - Sonar or Later / Destroy the Sonar Beacon!", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_med_failuretocommunicatesapphire_bay_obj21", "MED_PlayerObjective_FailureToCommunicateSapphire Bay_Obj21|MED_PlayerObjective_FailureToCommunicate");
    vars.targetNameLabels.Add("obj_name_med_failuretocommunicatesapphire_bay_obj21", "MED_PlayerObjective_FailureToCommunicateSapphire Bay_Obj21");
    settings.Add("obj_name_med_gotosapphire_bay_obj22", false, "Sapphire Bay - Path of Destruction / Investigate", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_med_gotosapphire_bay_obj22", "MED_PlayerObjective_GoToSapphire Bay_Obj22|MED_PlayerObjective_GoTo");
    vars.targetNameLabels.Add("obj_name_med_gotosapphire_bay_obj22", "MED_PlayerObjective_GoToSapphire Bay_Obj22");
    settings.Add("obj_name_terrorizesapphire_bay_obj23", false, "Sapphire Bay - Marina Rock / Consume 10 Sailors", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_terrorizesapphire_bay_obj23", "ME_PlayerObjectiveTerrorizeSapphire Bay_Obj23|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizesapphire_bay_obj23", "ME_PlayerObjectiveTerrorizeSapphire Bay_Obj23");
    settings.Add("obj_name_med_gotosapphire_bay_obj24", false, "Sapphire Bay - Yacht Topic / Investigate", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_med_gotosapphire_bay_obj24", "MED_PlayerObjective_GoToSapphire Bay_Obj24|MED_PlayerObjective_GoTo");
    vars.targetNameLabels.Add("obj_name_med_gotosapphire_bay_obj24", "MED_PlayerObjective_GoToSapphire Bay_Obj24");
    settings.Add("obj_name_me_huntobjectivesapphire_bay_obj25", false, "Sapphire Bay - Shock and Awe / Destroy the Target!", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_me_huntobjectivesapphire_bay_obj25", "ME_HuntObjectiveSapphire Bay_Obj25|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivesapphire_bay_obj25", "ME_HuntObjectiveSapphire Bay_Obj25");
    settings.Add("obj_name_me_huntobjectivesapphire_bay_obj26", false, "Sapphire Bay - Me and My Shadow / Destroy the Target!", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_me_huntobjectivesapphire_bay_obj26", "ME_HuntObjectiveSapphire Bay_Obj26|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivesapphire_bay_obj26", "ME_HuntObjectiveSapphire Bay_Obj26");
    settings.Add("obj_name_terrorizesapphire_bay_obj27", false, "Sapphire Bay - Freedom of Beach / Consume 10 Sailors", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_terrorizesapphire_bay_obj27", "ME_PlayerObjectiveTerrorizeSapphire Bay_Obj27|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizesapphire_bay_obj27", "ME_PlayerObjectiveTerrorizeSapphire Bay_Obj27");
    settings.Add("obj_name_terrorizesapphire_bay_obj28", false, "Sapphire Bay - Displeasure Island / Consume 10 Sailors", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_terrorizesapphire_bay_obj28", "ME_PlayerObjectiveTerrorizeSapphire Bay_Obj28|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizesapphire_bay_obj28", "ME_PlayerObjectiveTerrorizeSapphire Bay_Obj28");
    settings.Add("obj_name_med_timetrialsapphire_bay_obj29", false, "Sapphire Bay - Time Trial: The Liquidator / Swim through the rings.", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_med_timetrialsapphire_bay_obj29", "MED_PlayerObjectiveTimeTrialSapphire Bay_Obj29|MED_PlayerObjectiveTimeTrial");
    vars.targetNameLabels.Add("obj_name_med_timetrialsapphire_bay_obj29", "MED_PlayerObjectiveTimeTrialSapphire Bay_Obj29");
    settings.Add("obj_name_med_timetrialsapphire_bay_obj30", false, "Sapphire Bay - Time Trial: Nautical But Nice / Swim through the rings.", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_med_timetrialsapphire_bay_obj30", "MED_PlayerObjectiveTimeTrialSapphire Bay_Obj30|MED_PlayerObjectiveTimeTrial");
    vars.targetNameLabels.Add("obj_name_med_timetrialsapphire_bay_obj30", "MED_PlayerObjectiveTimeTrialSapphire Bay_Obj30");
    settings.Add("obj_name_med_tinfoilhatsapphire_bay_obj31", false, "Sapphire Bay - Sapphire Bay Quester Collector / Find All Questers", "region_sapphire_bay");
    vars.targetNames.Add("obj_name_med_tinfoilhatsapphire_bay_obj31", "MED_PlayerObjective_TinFoilHatSapphire Bay_Obj31|MED_PlayerObjective_TinFoilHat");
    vars.targetNameLabels.Add("obj_name_med_tinfoilhatsapphire_bay_obj31", "MED_PlayerObjective_TinFoilHatSapphire Bay_Obj31");

    settings.Add("region_prosperity_sands", true, "Prosperity Sands", "objective_splits");
    settings.Add("obj_name_grottoprosperity_sands_obj0", false, "Prosperity Sands - I'm A Cave 4 U / Visit the Prosperity Sands grotto", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_grottoprosperity_sands_obj0", "ME_PlayerObjectiveGrottoProsperity Sands_Obj0|ME_PlayerObjectiveGrotto");
    vars.targetNameLabels.Add("obj_name_grottoprosperity_sands_obj0", "ME_PlayerObjectiveGrottoProsperity Sands_Obj0");
    settings.Add("obj_name_terrorizeprosperity_sands_obj1", false, "Prosperity Sands - Disturb the Peace in Prosperity / Consume 15 Humans", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_terrorizeprosperity_sands_obj1", "ME_PlayerObjectiveTerrorizeProsperity Sands_Obj1|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizeprosperity_sands_obj1", "ME_PlayerObjectiveTerrorizeProsperity Sands_Obj1");
    settings.Add("obj_name_terrorizeprosperity_sands_obj2", false, "Prosperity Sands - Chopping Spree / Consume 10 Humans", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_terrorizeprosperity_sands_obj2", "ME_PlayerObjectiveTerrorizeProsperity Sands_Obj2|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizeprosperity_sands_obj2", "ME_PlayerObjectiveTerrorizeProsperity Sands_Obj2");
    settings.Add("obj_name_terrorizeprosperity_sands_obj3", false, "Prosperity Sands - Raving Lunatic / Consume 15 Humans", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_terrorizeprosperity_sands_obj3", "ME_PlayerObjectiveTerrorizeProsperity Sands_Obj3|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizeprosperity_sands_obj3", "ME_PlayerObjectiveTerrorizeProsperity Sands_Obj3");
    settings.Add("obj_name_terrorizeprosperity_sands_obj4", false, "Prosperity Sands - Beach Bummer / Consume 15 Humans", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_terrorizeprosperity_sands_obj4", "ME_PlayerObjectiveTerrorizeProsperity Sands_Obj4|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizeprosperity_sands_obj4", "ME_PlayerObjectiveTerrorizeProsperity Sands_Obj4");
    settings.Add("obj_name_terrorizeprosperity_sands_obj5", false, "Prosperity Sands - What's Up, Docks? / Consume 10 Humans", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_terrorizeprosperity_sands_obj5", "ME_PlayerObjectiveTerrorizeProsperity Sands_Obj5|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizeprosperity_sands_obj5", "ME_PlayerObjectiveTerrorizeProsperity Sands_Obj5");
    settings.Add("obj_name_me_huntobjectiveprosperity_sands_obj6", false, "Prosperity Sands - Roger & Me / Destroy the Target", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_me_huntobjectiveprosperity_sands_obj6", "ME_HuntObjectiveProsperity Sands_Obj6|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectiveprosperity_sands_obj6", "ME_HuntObjectiveProsperity Sands_Obj6");
    settings.Add("obj_name_me_huntobjectiveprosperity_sands_obj7", false, "Prosperity Sands - Mako It Happen / Destroy the Target", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_me_huntobjectiveprosperity_sands_obj7", "ME_HuntObjectiveProsperity Sands_Obj7|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectiveprosperity_sands_obj7", "ME_HuntObjectiveProsperity Sands_Obj7");
    settings.Add("obj_name_me_huntobjectiveprosperity_sands_obj8", false, "Prosperity Sands - Jump the Shark / Destroy the Target", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_me_huntobjectiveprosperity_sands_obj8", "ME_HuntObjectiveProsperity Sands_Obj8|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectiveprosperity_sands_obj8", "ME_HuntObjectiveProsperity Sands_Obj8");
    settings.Add("obj_name_me_huntobjectiveprosperity_sands_obj9", false, "Prosperity Sands - A Hard Day's White / Destroy the Target", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_me_huntobjectiveprosperity_sands_obj9", "ME_HuntObjectiveProsperity Sands_Obj9|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectiveprosperity_sands_obj9", "ME_HuntObjectiveProsperity Sands_Obj9");
    settings.Add("obj_name_me_huntobjectiveprosperity_sands_obj10", false, "Prosperity Sands - Wish Sewer Here  / Destroy the Target", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_me_huntobjectiveprosperity_sands_obj10", "ME_HuntObjectiveProsperity Sands_Obj10|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectiveprosperity_sands_obj10", "ME_HuntObjectiveProsperity Sands_Obj10");
    settings.Add("obj_name_populationcontrolprosperity_sands_obj11", false, "Prosperity Sands - Seal Their Fate / Kill 10 Seals", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_populationcontrolprosperity_sands_obj11", "ME_PlayerObjectivePopulationControlProsperity Sands_Obj11|ME_PlayerObjectivePopulationControl");
    vars.targetNameLabels.Add("obj_name_populationcontrolprosperity_sands_obj11", "ME_PlayerObjectivePopulationControlProsperity Sands_Obj11");
    settings.Add("obj_name_populationcontrolprosperity_sands_obj12", false, "Prosperity Sands - Off the Menu / Kill 10 Seals", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_populationcontrolprosperity_sands_obj12", "ME_PlayerObjectivePopulationControlProsperity Sands_Obj12|ME_PlayerObjectivePopulationControl");
    vars.targetNameLabels.Add("obj_name_populationcontrolprosperity_sands_obj12", "ME_PlayerObjectivePopulationControlProsperity Sands_Obj12");
    settings.Add("obj_name_populationcontrolprosperity_sands_obj13", false, "Prosperity Sands - Pinniped Problems / Kill 10 Seals", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_populationcontrolprosperity_sands_obj13", "ME_PlayerObjectivePopulationControlProsperity Sands_Obj13|ME_PlayerObjectivePopulationControl");
    vars.targetNameLabels.Add("obj_name_populationcontrolprosperity_sands_obj13", "ME_PlayerObjectivePopulationControlProsperity Sands_Obj13");
    settings.Add("obj_name_me_killobjectiveprosperity_sands_obj14", false, "Prosperity Sands - Royal Flush / Kill the Apex", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_me_killobjectiveprosperity_sands_obj14", "ME_KillObjectiveProsperity Sands_Obj14|ME_KillObjective");
    vars.targetNameLabels.Add("obj_name_me_killobjectiveprosperity_sands_obj14", "ME_KillObjectiveProsperity Sands_Obj14");
    settings.Add("obj_name_landmarkprosperity_sands_obj15", false, "Prosperity Sands - Prosperity Sands Landmarks / Discover all Landmarks", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_landmarkprosperity_sands_obj15", "ME_PlayerObjectiveLandmarkProsperity Sands_Obj15|ME_PlayerObjectiveLandmark");
    vars.targetNameLabels.Add("obj_name_landmarkprosperity_sands_obj15", "ME_PlayerObjectiveLandmarkProsperity Sands_Obj15");
    settings.Add("obj_name_nutrientcacheprosperity_sands_obj16", false, "Prosperity Sands - Prosperity Sands Nutrient Caches / Collect all Caches", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_nutrientcacheprosperity_sands_obj16", "ME_PlayerObjectiveNutrientCacheProsperity Sands_Obj16|ME_PlayerObjectiveNutrientCache");
    vars.targetNameLabels.Add("obj_name_nutrientcacheprosperity_sands_obj16", "ME_PlayerObjectiveNutrientCacheProsperity Sands_Obj16");
    settings.Add("obj_name_collectableprosperity_sands_obj17", false, "Prosperity Sands - Prosperity Prizes / Collect all License Plates", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_collectableprosperity_sands_obj17", "ME_PlayerObjectiveCollectableProsperity Sands_Obj17|ME_PlayerObjectiveCollectable");
    vars.targetNameLabels.Add("obj_name_collectableprosperity_sands_obj17", "ME_PlayerObjectiveCollectableProsperity Sands_Obj17");
    settings.Add("obj_name_gatesprosperity_sands_obj18", false, "Prosperity Sands - Prosperity Sands Gate", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_gatesprosperity_sands_obj18", "ME_PlayerObjectiveGatesProsperity Sands_Obj18|ME_PlayerObjectiveGates");
    vars.targetNameLabels.Add("obj_name_gatesprosperity_sands_obj18", "ME_PlayerObjectiveGatesProsperity Sands_Obj18");
    settings.Add("obj_name_gratesprosperity_sands_obj19", false, "Prosperity Sands - Prosperity Sands Grates", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_gratesprosperity_sands_obj19", "ME_PlayerObjectiveGratesProsperity Sands_Obj19|ME_PlayerObjectiveGrates");
    vars.targetNameLabels.Add("obj_name_gratesprosperity_sands_obj19", "ME_PlayerObjectiveGratesProsperity Sands_Obj19");
    settings.Add("obj_name_cutsceneprosperity_sands_obj20", false, "Prosperity Sands - \"Fish Food\" / Check in on Pete, again", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_cutsceneprosperity_sands_obj20", "ME_PlayerObjectiveCutsceneProsperity Sands_Obj20|ME_PlayerObjectiveCutscene");
    vars.targetNameLabels.Add("obj_name_cutsceneprosperity_sands_obj20", "ME_PlayerObjectiveCutsceneProsperity Sands_Obj20");
    settings.Add("obj_name_med_gotoprosperity_sands_obj21", false, "Prosperity Sands - Radiation Pattern / Investigate", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_med_gotoprosperity_sands_obj21", "MED_PlayerObjective_GoToProsperity Sands_Obj21|MED_PlayerObjective_GoTo");
    vars.targetNameLabels.Add("obj_name_med_gotoprosperity_sands_obj21", "MED_PlayerObjective_GoToProsperity Sands_Obj21");
    settings.Add("obj_name_terrorizeprosperity_sands_obj22", false, "Prosperity Sands - Navy Squeals / Consume 10 Sailors", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_terrorizeprosperity_sands_obj22", "ME_PlayerObjectiveTerrorizeProsperity Sands_Obj22|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizeprosperity_sands_obj22", "ME_PlayerObjectiveTerrorizeProsperity Sands_Obj22");
    settings.Add("obj_name_med_gotoprosperity_sands_obj23", false, "Prosperity Sands - Getting Warmer... / Investigate", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_med_gotoprosperity_sands_obj23", "MED_PlayerObjective_GoToProsperity Sands_Obj23|MED_PlayerObjective_GoTo");
    vars.targetNameLabels.Add("obj_name_med_gotoprosperity_sands_obj23", "MED_PlayerObjective_GoToProsperity Sands_Obj23");
    settings.Add("obj_name_me_huntobjectiveprosperity_sands_obj24", false, "Prosperity Sands - Rock the Volt / Destroy the Target!", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_me_huntobjectiveprosperity_sands_obj24", "ME_HuntObjectiveProsperity Sands_Obj24|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectiveprosperity_sands_obj24", "ME_HuntObjectiveProsperity Sands_Obj24");
    settings.Add("obj_name_me_huntobjectiveprosperity_sands_obj25", false, "Prosperity Sands - Throwing Shade / Destroy the Target!", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_me_huntobjectiveprosperity_sands_obj25", "ME_HuntObjectiveProsperity Sands_Obj25|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectiveprosperity_sands_obj25", "ME_HuntObjectiveProsperity Sands_Obj25");
    settings.Add("obj_name_terrorizeprosperity_sands_obj26", false, "Prosperity Sands - Boardwalk Bites / Consume 10 Sailors", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_terrorizeprosperity_sands_obj26", "ME_PlayerObjectiveTerrorizeProsperity Sands_Obj26|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizeprosperity_sands_obj26", "ME_PlayerObjectiveTerrorizeProsperity Sands_Obj26");
    settings.Add("obj_name_terrorizeprosperity_sands_obj27", false, "Prosperity Sands - Thank You for Your Disservice / Consume 10 Sailors", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_terrorizeprosperity_sands_obj27", "ME_PlayerObjectiveTerrorizeProsperity Sands_Obj27|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizeprosperity_sands_obj27", "ME_PlayerObjectiveTerrorizeProsperity Sands_Obj27");
    settings.Add("obj_name_med_timetrialprosperity_sands_obj28", false, "Prosperity Sands - Time Trial: Deep Float / Swim through the rings.", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_med_timetrialprosperity_sands_obj28", "MED_PlayerObjectiveTimeTrialProsperity Sands_Obj28|MED_PlayerObjectiveTimeTrial");
    vars.targetNameLabels.Add("obj_name_med_timetrialprosperity_sands_obj28", "MED_PlayerObjectiveTimeTrialProsperity Sands_Obj28");
    settings.Add("obj_name_med_timetrialprosperity_sands_obj29", false, "Prosperity Sands - Time Trial: Last Splash / Swim through the rings.", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_med_timetrialprosperity_sands_obj29", "MED_PlayerObjectiveTimeTrialProsperity Sands_Obj29|MED_PlayerObjectiveTimeTrial");
    vars.targetNameLabels.Add("obj_name_med_timetrialprosperity_sands_obj29", "MED_PlayerObjectiveTimeTrialProsperity Sands_Obj29");
    settings.Add("obj_name_med_tinfoilhatprosperity_sands_obj30", false, "Prosperity Sands - Prosperity Sands Quester Collector / Find All Questers", "region_prosperity_sands");
    vars.targetNames.Add("obj_name_med_tinfoilhatprosperity_sands_obj30", "MED_PlayerObjective_TinFoilHatProsperity Sands_Obj30|MED_PlayerObjective_TinFoilHat");
    vars.targetNameLabels.Add("obj_name_med_tinfoilhatprosperity_sands_obj30", "MED_PlayerObjective_TinFoilHatProsperity Sands_Obj30");

    settings.Add("region_caviar_key", true, "Caviar Key", "objective_splits");
    settings.Add("obj_name_grottocaviar_key_obj0", false, "Caviar Key - Whole Grotto Love / Visit the Caviar Key grotto", "region_caviar_key");
    vars.targetNames.Add("obj_name_grottocaviar_key_obj0", "ME_PlayerObjectiveGrottoCaviar Key_Obj0|ME_PlayerObjectiveGrotto");
    vars.targetNameLabels.Add("obj_name_grottocaviar_key_obj0", "ME_PlayerObjectiveGrottoCaviar Key_Obj0");
    settings.Add("obj_name_terrorizecaviar_key_obj1", false, "Caviar Key - Finger Food / Consume 10 Humans", "region_caviar_key");
    vars.targetNames.Add("obj_name_terrorizecaviar_key_obj1", "ME_PlayerObjectiveTerrorizeCaviar Key_Obj1|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizecaviar_key_obj1", "ME_PlayerObjectiveTerrorizeCaviar Key_Obj1");
    settings.Add("obj_name_terrorizecaviar_key_obj2", false, "Caviar Key - Construction Bite / Consume 10 Humans", "region_caviar_key");
    vars.targetNames.Add("obj_name_terrorizecaviar_key_obj2", "ME_PlayerObjectiveTerrorizeCaviar Key_Obj2|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizecaviar_key_obj2", "ME_PlayerObjectiveTerrorizeCaviar Key_Obj2");
    settings.Add("obj_name_terrorizecaviar_key_obj3", false, "Caviar Key - Skate and Die / Consume 15 Humans", "region_caviar_key");
    vars.targetNames.Add("obj_name_terrorizecaviar_key_obj3", "ME_PlayerObjectiveTerrorizeCaviar Key_Obj3|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizecaviar_key_obj3", "ME_PlayerObjectiveTerrorizeCaviar Key_Obj3");
    settings.Add("obj_name_terrorizecaviar_key_obj4", false, "Caviar Key - Pond Scum / Consume 10 Humans", "region_caviar_key");
    vars.targetNames.Add("obj_name_terrorizecaviar_key_obj4", "ME_PlayerObjectiveTerrorizeCaviar Key_Obj4|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizecaviar_key_obj4", "ME_PlayerObjectiveTerrorizeCaviar Key_Obj4");
    settings.Add("obj_name_terrorizecaviar_key_obj5", false, "Caviar Key - Walk This Way / Consume 10 Humans", "region_caviar_key");
    vars.targetNames.Add("obj_name_terrorizecaviar_key_obj5", "ME_PlayerObjectiveTerrorizeCaviar Key_Obj5|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizecaviar_key_obj5", "ME_PlayerObjectiveTerrorizeCaviar Key_Obj5");
    settings.Add("obj_name_me_huntobjectivecaviar_key_obj6", false, "Caviar Key - Black and White and Dead All Over / Destroy the Target", "region_caviar_key");
    vars.targetNames.Add("obj_name_me_huntobjectivecaviar_key_obj6", "ME_HuntObjectiveCaviar Key_Obj6|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivecaviar_key_obj6", "ME_HuntObjectiveCaviar Key_Obj6");
    settings.Add("obj_name_me_huntobjectivecaviar_key_obj7", false, "Caviar Key - Jaws for Alarm / Destroy the Target", "region_caviar_key");
    vars.targetNames.Add("obj_name_me_huntobjectivecaviar_key_obj7", "ME_HuntObjectiveCaviar Key_Obj7|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivecaviar_key_obj7", "ME_HuntObjectiveCaviar Key_Obj7");
    settings.Add("obj_name_me_huntobjectivecaviar_key_obj8", false, "Caviar Key - Hammer? Please Hurt 'Em / Destroy the Target", "region_caviar_key");
    vars.targetNames.Add("obj_name_me_huntobjectivecaviar_key_obj8", "ME_HuntObjectiveCaviar Key_Obj8|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivecaviar_key_obj8", "ME_HuntObjectiveCaviar Key_Obj8");
    settings.Add("obj_name_me_huntobjectivecaviar_key_obj9", false, "Caviar Key - Something to Pond-er / Destroy the Target", "region_caviar_key");
    vars.targetNames.Add("obj_name_me_huntobjectivecaviar_key_obj9", "ME_HuntObjectiveCaviar Key_Obj9|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivecaviar_key_obj9", "ME_HuntObjectiveCaviar Key_Obj9");
    settings.Add("obj_name_me_huntobjectivecaviar_key_obj10", false, "Caviar Key - Trawl in a Day's Work / Destroy the Target", "region_caviar_key");
    vars.targetNames.Add("obj_name_me_huntobjectivecaviar_key_obj10", "ME_HuntObjectiveCaviar Key_Obj10|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivecaviar_key_obj10", "ME_HuntObjectiveCaviar Key_Obj10");
    settings.Add("obj_name_populationcontrolcaviar_key_obj11", false, "Caviar Key - A Turtle Disaster / Kill 10 Turtles", "region_caviar_key");
    vars.targetNames.Add("obj_name_populationcontrolcaviar_key_obj11", "ME_PlayerObjectivePopulationControlCaviar Key_Obj11|ME_PlayerObjectivePopulationControl");
    vars.targetNameLabels.Add("obj_name_populationcontrolcaviar_key_obj11", "ME_PlayerObjectivePopulationControlCaviar Key_Obj11");
    settings.Add("obj_name_populationcontrolcaviar_key_obj12", false, "Caviar Key - What the Shell? / Kill 10 Turtles", "region_caviar_key");
    vars.targetNames.Add("obj_name_populationcontrolcaviar_key_obj12", "ME_PlayerObjectivePopulationControlCaviar Key_Obj12|ME_PlayerObjectivePopulationControl");
    vars.targetNameLabels.Add("obj_name_populationcontrolcaviar_key_obj12", "ME_PlayerObjectivePopulationControlCaviar Key_Obj12");
    settings.Add("obj_name_populationcontrolcaviar_key_obj13", false, "Caviar Key - Slow Pokes / Kill 10 Turtles", "region_caviar_key");
    vars.targetNames.Add("obj_name_populationcontrolcaviar_key_obj13", "ME_PlayerObjectivePopulationControlCaviar Key_Obj13|ME_PlayerObjectivePopulationControl");
    vars.targetNameLabels.Add("obj_name_populationcontrolcaviar_key_obj13", "ME_PlayerObjectivePopulationControlCaviar Key_Obj13");
    settings.Add("obj_name_me_killobjectivecaviar_key_obj14", false, "Caviar Key - Killer Queen / Kill the Apex", "region_caviar_key");
    vars.targetNames.Add("obj_name_me_killobjectivecaviar_key_obj14", "ME_KillObjectiveCaviar Key_Obj14|ME_KillObjective");
    vars.targetNameLabels.Add("obj_name_me_killobjectivecaviar_key_obj14", "ME_KillObjectiveCaviar Key_Obj14");
    settings.Add("obj_name_landmarkcaviar_key_obj15", false, "Caviar Key - Caviar Key Landmarks / Discover all Landmarks", "region_caviar_key");
    vars.targetNames.Add("obj_name_landmarkcaviar_key_obj15", "ME_PlayerObjectiveLandmarkCaviar Key_Obj15|ME_PlayerObjectiveLandmark");
    vars.targetNameLabels.Add("obj_name_landmarkcaviar_key_obj15", "ME_PlayerObjectiveLandmarkCaviar Key_Obj15");
    settings.Add("obj_name_nutrientcachecaviar_key_obj16", false, "Caviar Key - Caviar Key Nutrient Caches / Collect all Caches", "region_caviar_key");
    vars.targetNames.Add("obj_name_nutrientcachecaviar_key_obj16", "ME_PlayerObjectiveNutrientCacheCaviar Key_Obj16|ME_PlayerObjectiveNutrientCache");
    vars.targetNameLabels.Add("obj_name_nutrientcachecaviar_key_obj16", "ME_PlayerObjectiveNutrientCacheCaviar Key_Obj16");
    settings.Add("obj_name_collectablecaviar_key_obj17", false, "Caviar Key - Caviar Keypsakes / Collect all License Plates", "region_caviar_key");
    vars.targetNames.Add("obj_name_collectablecaviar_key_obj17", "ME_PlayerObjectiveCollectableCaviar Key_Obj17|ME_PlayerObjectiveCollectable");
    vars.targetNameLabels.Add("obj_name_collectablecaviar_key_obj17", "ME_PlayerObjectiveCollectableCaviar Key_Obj17");
    settings.Add("obj_name_gatescaviar_key_obj18", false, "Caviar Key - Caviar Key Gate", "region_caviar_key");
    vars.targetNames.Add("obj_name_gatescaviar_key_obj18", "ME_PlayerObjectiveGatesCaviar Key_Obj18|ME_PlayerObjectiveGates");
    vars.targetNameLabels.Add("obj_name_gatescaviar_key_obj18", "ME_PlayerObjectiveGatesCaviar Key_Obj18");
    settings.Add("obj_name_gratescaviar_key_obj19", false, "Caviar Key - Caviar Key Grates", "region_caviar_key");
    vars.targetNames.Add("obj_name_gratescaviar_key_obj19", "ME_PlayerObjectiveGratesCaviar Key_Obj19|ME_PlayerObjectiveGrates");
    vars.targetNameLabels.Add("obj_name_gratescaviar_key_obj19", "ME_PlayerObjectiveGratesCaviar Key_Obj19");
    settings.Add("obj_name_med_failuretocommunicatecaviar_key_obj20", false, "Caviar Key - Satellite for Destruction / Destroy the Comms Beacon!", "region_caviar_key");
    vars.targetNames.Add("obj_name_med_failuretocommunicatecaviar_key_obj20", "MED_PlayerObjective_FailureToCommunicateCaviar Key_Obj20|MED_PlayerObjective_FailureToCommunicate");
    vars.targetNameLabels.Add("obj_name_med_failuretocommunicatecaviar_key_obj20", "MED_PlayerObjective_FailureToCommunicateCaviar Key_Obj20");
    settings.Add("obj_name_med_tinfoilhatcaviar_key_obj21", false, "Caviar Key - Caviar Key Quester Collector / Find All Questers", "region_caviar_key");
    vars.targetNames.Add("obj_name_med_tinfoilhatcaviar_key_obj21", "MED_PlayerObjective_TinFoilHatCaviar Key_Obj21|MED_PlayerObjective_TinFoilHat");
    vars.targetNameLabels.Add("obj_name_med_tinfoilhatcaviar_key_obj21", "MED_PlayerObjective_TinFoilHatCaviar Key_Obj21");

    settings.Add("region_the_gulf", true, "The Gulf", "objective_splits");
    settings.Add("obj_name_grottothe_gulf_obj0", false, "The Gulf - Cave, the Best for Last / Visit the Gulf grotto", "region_the_gulf");
    vars.targetNames.Add("obj_name_grottothe_gulf_obj0", "ME_PlayerObjectiveGrottoThe Gulf_Obj0|ME_PlayerObjectiveGrotto");
    vars.targetNameLabels.Add("obj_name_grottothe_gulf_obj0", "ME_PlayerObjectiveGrottoThe Gulf_Obj0");
    settings.Add("obj_name_terrorizethe_gulf_obj1", false, "The Gulf - Oil's Well That Ends Well / Consume 5 Humans", "region_the_gulf");
    vars.targetNames.Add("obj_name_terrorizethe_gulf_obj1", "ME_PlayerObjectiveTerrorizeThe Gulf_Obj1|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizethe_gulf_obj1", "ME_PlayerObjectiveTerrorizeThe Gulf_Obj1");
    settings.Add("obj_name_terrorizethe_gulf_obj2", false, "The Gulf - A Fright at the Museum / Consume 10 Humans", "region_the_gulf");
    vars.targetNames.Add("obj_name_terrorizethe_gulf_obj2", "ME_PlayerObjectiveTerrorizeThe Gulf_Obj2|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizethe_gulf_obj2", "ME_PlayerObjectiveTerrorizeThe Gulf_Obj2");
    settings.Add("obj_name_terrorizethe_gulf_obj3", false, "The Gulf - Undiscovered Treasure / Consume 5 Humans", "region_the_gulf");
    vars.targetNames.Add("obj_name_terrorizethe_gulf_obj3", "ME_PlayerObjectiveTerrorizeThe Gulf_Obj3|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizethe_gulf_obj3", "ME_PlayerObjectiveTerrorizeThe Gulf_Obj3");
    settings.Add("obj_name_terrorizethe_gulf_obj4", false, "The Gulf - Routine Maintenance / Consume 5 Humans", "region_the_gulf");
    vars.targetNames.Add("obj_name_terrorizethe_gulf_obj4", "ME_PlayerObjectiveTerrorizeThe Gulf_Obj4|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizethe_gulf_obj4", "ME_PlayerObjectiveTerrorizeThe Gulf_Obj4");
    settings.Add("obj_name_terrorizethe_gulf_obj5", false, "The Gulf - Reef Chow Fun / Consume 5 Humans", "region_the_gulf");
    vars.targetNames.Add("obj_name_terrorizethe_gulf_obj5", "ME_PlayerObjectiveTerrorizeThe Gulf_Obj5|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_name_terrorizethe_gulf_obj5", "ME_PlayerObjectiveTerrorizeThe Gulf_Obj5");
    settings.Add("obj_name_me_huntobjectivethe_gulf_obj6", false, "The Gulf - Yacht-Blooded / Destroy the Target", "region_the_gulf");
    vars.targetNames.Add("obj_name_me_huntobjectivethe_gulf_obj6", "ME_HuntObjectiveThe Gulf_Obj6|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivethe_gulf_obj6", "ME_HuntObjectiveThe Gulf_Obj6");
    settings.Add("obj_name_me_huntobjectivethe_gulf_obj7", false, "The Gulf - Sewer Cetacean / Destroy the Target", "region_the_gulf");
    vars.targetNames.Add("obj_name_me_huntobjectivethe_gulf_obj7", "ME_HuntObjectiveThe Gulf_Obj7|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivethe_gulf_obj7", "ME_HuntObjectiveThe Gulf_Obj7");
    settings.Add("obj_name_me_huntobjectivethe_gulf_obj8", false, "The Gulf - Whale-Heeled / Destroy the Target", "region_the_gulf");
    vars.targetNames.Add("obj_name_me_huntobjectivethe_gulf_obj8", "ME_HuntObjectiveThe Gulf_Obj8|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivethe_gulf_obj8", "ME_HuntObjectiveThe Gulf_Obj8");
    settings.Add("obj_name_me_huntobjectivethe_gulf_obj9", false, "The Gulf - Any Fin Goes / Destroy the Target", "region_the_gulf");
    vars.targetNames.Add("obj_name_me_huntobjectivethe_gulf_obj9", "ME_HuntObjectiveThe Gulf_Obj9|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivethe_gulf_obj9", "ME_HuntObjectiveThe Gulf_Obj9");
    settings.Add("obj_name_me_huntobjectivethe_gulf_obj10", false, "The Gulf - The Legend of Bobby Lee's Gold  / Destroy the Target", "region_the_gulf");
    vars.targetNames.Add("obj_name_me_huntobjectivethe_gulf_obj10", "ME_HuntObjectiveThe Gulf_Obj10|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivethe_gulf_obj10", "ME_HuntObjectiveThe Gulf_Obj10");
    settings.Add("obj_name_populationcontrolthe_gulf_obj11", false, "The Gulf - Swimming With the Sharks / Kill 10 Hammerheads", "region_the_gulf");
    vars.targetNames.Add("obj_name_populationcontrolthe_gulf_obj11", "ME_PlayerObjectivePopulationControlThe Gulf_Obj11|ME_PlayerObjectivePopulationControl");
    vars.targetNameLabels.Add("obj_name_populationcontrolthe_gulf_obj11", "ME_PlayerObjectivePopulationControlThe Gulf_Obj11");
    settings.Add("obj_name_populationcontrolthe_gulf_obj12", false, "The Gulf - Hammer Horror / Kill 10 Hammerheads", "region_the_gulf");
    vars.targetNames.Add("obj_name_populationcontrolthe_gulf_obj12", "ME_PlayerObjectivePopulationControlThe Gulf_Obj12|ME_PlayerObjectivePopulationControl");
    vars.targetNameLabels.Add("obj_name_populationcontrolthe_gulf_obj12", "ME_PlayerObjectivePopulationControlThe Gulf_Obj12");
    settings.Add("obj_name_populationcontrolthe_gulf_obj13", false, "The Gulf - Wide-Eyed / Kill 10 Hammerheads", "region_the_gulf");
    vars.targetNames.Add("obj_name_populationcontrolthe_gulf_obj13", "ME_PlayerObjectivePopulationControlThe Gulf_Obj13|ME_PlayerObjectivePopulationControl");
    vars.targetNameLabels.Add("obj_name_populationcontrolthe_gulf_obj13", "ME_PlayerObjectivePopulationControlThe Gulf_Obj13");
    settings.Add("obj_name_nutrientcachethe_gulf_obj14", false, "The Gulf - The Gulf Nutrient Cache / Collect all Caches", "region_the_gulf");
    vars.targetNames.Add("obj_name_nutrientcachethe_gulf_obj14", "ME_PlayerObjectiveNutrientCacheThe Gulf_Obj14|ME_PlayerObjectiveNutrientCache");
    vars.targetNameLabels.Add("obj_name_nutrientcachethe_gulf_obj14", "ME_PlayerObjectiveNutrientCacheThe Gulf_Obj14");
    settings.Add("obj_name_me_killobjectivethe_gulf_obj15", false, "The Gulf - You've Got Whale / Kill the Apex", "region_the_gulf");
    vars.targetNames.Add("obj_name_me_killobjectivethe_gulf_obj15", "ME_KillObjectiveThe Gulf_Obj15|ME_KillObjective");
    vars.targetNameLabels.Add("obj_name_me_killobjectivethe_gulf_obj15", "ME_KillObjectiveThe Gulf_Obj15");
    settings.Add("obj_name_collectablethe_gulf_obj16", false, "The Gulf - Gulf Gewgaws / Collect all License Plates", "region_the_gulf");
    vars.targetNames.Add("obj_name_collectablethe_gulf_obj16", "ME_PlayerObjectiveCollectableThe Gulf_Obj16|ME_PlayerObjectiveCollectable");
    vars.targetNameLabels.Add("obj_name_collectablethe_gulf_obj16", "ME_PlayerObjectiveCollectableThe Gulf_Obj16");
    settings.Add("obj_name_landmarkthe_gulf_obj17", false, "The Gulf - The Gulf Landmarks / Discover all Landmarks", "region_the_gulf");
    vars.targetNames.Add("obj_name_landmarkthe_gulf_obj17", "ME_PlayerObjectiveLandmarkThe Gulf_Obj17|ME_PlayerObjectiveLandmark");
    vars.targetNameLabels.Add("obj_name_landmarkthe_gulf_obj17", "ME_PlayerObjectiveLandmarkThe Gulf_Obj17");
    settings.Add("obj_name_gratesthe_gulf_obj18", false, "The Gulf - The Gulf Grates", "region_the_gulf");
    vars.targetNames.Add("obj_name_gratesthe_gulf_obj18", "ME_PlayerObjectiveGratesThe Gulf_Obj18|ME_PlayerObjectiveGrates");
    vars.targetNameLabels.Add("obj_name_gratesthe_gulf_obj18", "ME_PlayerObjectiveGratesThe Gulf_Obj18");
    settings.Add("obj_name_cutscenethe_gulf_obj19", false, "The Gulf - A Bigger Boat / Get a peek at Pete's new vessel", "region_the_gulf");
    vars.targetNames.Add("obj_name_cutscenethe_gulf_obj19", "ME_PlayerObjectiveCutsceneThe Gulf_Obj19|ME_PlayerObjectiveCutscene");
    vars.targetNameLabels.Add("obj_name_cutscenethe_gulf_obj19", "ME_PlayerObjectiveCutsceneThe Gulf_Obj19");
    settings.Add("obj_name_bossthe_gulf_obj20", false, "The Gulf - Mega Shark vs. PT 522 / Take on Pete and his refurbished World War II-era attack vessel", "region_the_gulf");
    vars.targetNames.Add("obj_name_bossthe_gulf_obj20", "ME_PlayerObjectiveBossThe Gulf_Obj20|ME_PlayerObjectiveBoss");
    vars.targetNameLabels.Add("obj_name_bossthe_gulf_obj20", "ME_PlayerObjectiveBossThe Gulf_Obj20");
    settings.Add("obj_name_cutscenethe_gulf_obj21", false, "The Gulf - Uncommon Scents / Investigate ", "region_the_gulf");
    vars.targetNames.Add("obj_name_cutscenethe_gulf_obj21", "ME_PlayerObjectiveCutsceneThe Gulf_Obj21|ME_PlayerObjectiveCutscene");
    vars.targetNameLabels.Add("obj_name_cutscenethe_gulf_obj21", "ME_PlayerObjectiveCutsceneThe Gulf_Obj21");
    settings.Add("obj_name_med_timetrialthe_gulf_obj22", false, "The Gulf - Chase Champion / Swim through the rings.", "region_the_gulf");
    vars.targetNames.Add("obj_name_med_timetrialthe_gulf_obj22", "MED_PlayerObjectiveTimeTrialThe Gulf_Obj22|MED_PlayerObjectiveTimeTrial");
    vars.targetNameLabels.Add("obj_name_med_timetrialthe_gulf_obj22", "MED_PlayerObjectiveTimeTrialThe Gulf_Obj22");
    settings.Add("obj_name_me_huntobjectivethe_gulf_obj23", false, "The Gulf - Ship Search / Destroy the Target", "region_the_gulf");
    vars.targetNames.Add("obj_name_me_huntobjectivethe_gulf_obj23", "ME_HuntObjectiveThe Gulf_Obj23|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_name_me_huntobjectivethe_gulf_obj23", "ME_HuntObjectiveThe Gulf_Obj23");
    settings.Add("obj_name_med_gotothe_gulf_obj24", false, "The Gulf - Run for Plover / Investigate", "region_the_gulf");
    vars.targetNames.Add("obj_name_med_gotothe_gulf_obj24", "MED_PlayerObjective_GoToThe Gulf_Obj24|MED_PlayerObjective_GoTo");
    vars.targetNameLabels.Add("obj_name_med_gotothe_gulf_obj24", "MED_PlayerObjective_GoToThe Gulf_Obj24");
    settings.Add("obj_name_med_gotothe_gulf_obj25", false, "The Gulf - Stone Killer / Investigate", "region_the_gulf");
    vars.targetNames.Add("obj_name_med_gotothe_gulf_obj25", "MED_PlayerObjective_GoToThe Gulf_Obj25|MED_PlayerObjective_GoTo");
    vars.targetNameLabels.Add("obj_name_med_gotothe_gulf_obj25", "MED_PlayerObjective_GoToThe Gulf_Obj25");
    settings.Add("obj_name_med_gotothe_gulf_obj26", false, "The Gulf - Unhappy Trails / Investigate", "region_the_gulf");
    vars.targetNames.Add("obj_name_med_gotothe_gulf_obj26", "MED_PlayerObjective_GoToThe Gulf_Obj26|MED_PlayerObjective_GoTo");
    vars.targetNameLabels.Add("obj_name_med_gotothe_gulf_obj26", "MED_PlayerObjective_GoToThe Gulf_Obj26");
    settings.Add("obj_name_med_gotothe_gulf_obj27", false, "The Gulf - You're Hot! / Investigate", "region_the_gulf");
    vars.targetNames.Add("obj_name_med_gotothe_gulf_obj27", "MED_PlayerObjective_GoToThe Gulf_Obj27|MED_PlayerObjective_GoTo");
    vars.targetNameLabels.Add("obj_name_med_gotothe_gulf_obj27", "MED_PlayerObjective_GoToThe Gulf_Obj27");
    settings.Add("obj_name_me_killobjectivethe_gulf_obj28", false, "The Gulf - Alpha Wave / Kill the Apex", "region_the_gulf");
    vars.targetNames.Add("obj_name_me_killobjectivethe_gulf_obj28", "ME_KillObjectiveThe Gulf_Obj28|ME_KillObjective");
    vars.targetNameLabels.Add("obj_name_me_killobjectivethe_gulf_obj28", "ME_KillObjectiveThe Gulf_Obj28");
    settings.Add("obj_name_med_tinfoilhatthe_gulf_obj29", false, "The Gulf - The Gulf Quester Collector / Find All Questers", "region_the_gulf");
    vars.targetNames.Add("obj_name_med_tinfoilhatthe_gulf_obj29", "MED_PlayerObjective_TinFoilHatThe Gulf_Obj29|MED_PlayerObjective_TinFoilHat");
    vars.targetNameLabels.Add("obj_name_med_tinfoilhatthe_gulf_obj29", "MED_PlayerObjective_TinFoilHatThe Gulf_Obj29");




    settings.Add("region_dlc_chidori", true, "DLC - Chidori Island / Truth Quest", "objective_splits");

    settings.Add("obj_dlc_name_me_huntobjectivedlc_obj0", false, "DLC - Chidori Island - Go For the Boat  / Destroy the Target", "region_dlc_chidori");
    vars.targetNames.Add("obj_dlc_name_me_huntobjectivedlc_obj0", "ME_HuntObjectiveDLC Region 1_Obj0|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_dlc_name_me_huntobjectivedlc_obj0", "ME_HuntObjectiveDLC Region 1_Obj0");
    settings.Add("obj_dlc_name_me_playerobjectivegrottodlc_obj1", false, "DLC - Chidori Island - Gimme Shelter / Visit the Plover Island grotto", "region_dlc_chidori");
    vars.targetNames.Add("obj_dlc_name_me_playerobjectivegrottodlc_obj1", "ME_PlayerObjectiveGrottoDLC Region 1_Obj1|ME_PlayerObjectiveGrotto");
    vars.targetNameLabels.Add("obj_dlc_name_me_playerobjectivegrottodlc_obj1", "ME_PlayerObjectiveGrottoDLC Region 1_Obj1");
    settings.Add("obj_dlc_name_med_playerobjective_failuretocommunicatedlc_obj2", false, "DLC - Chidori Island - Filet-O-Dish / Destroy the Comms Beacon!", "region_dlc_chidori");
    vars.targetNames.Add("obj_dlc_name_med_playerobjective_failuretocommunicatedlc_obj2", "MED_PlayerObjective_FailureToCommunicateDLC Region 1_Obj2|MED_PlayerObjective_FailureToCommunicate");
    vars.targetNameLabels.Add("obj_dlc_name_med_playerobjective_failuretocommunicatedlc_obj2", "MED_PlayerObjective_FailureToCommunicateDLC Region 1_Obj2");
    settings.Add("obj_dlc_guid_escape_plan", false, "DLC - Chidori Island - Escape Plan / Swim through the rings.", "region_dlc_chidori");
    vars.targetGuids["obj_dlc_guid_escape_plan"] = new uint[] { 0xC2D70F8Cu, 0x42FBF027u, 0x0AF1D18Bu, 0xAA183E9Fu };
    vars.targetOrder.Add("obj_dlc_guid_escape_plan");
    settings.Add("obj_dlc_name_me_playerobjectivepopulationcontroldlc_obj4", false, "DLC - Chidori Island - Stop! Hammer Time / Kill 5 Hammerheads", "region_dlc_chidori");
    vars.targetNames.Add("obj_dlc_name_me_playerobjectivepopulationcontroldlc_obj4", "ME_PlayerObjectivePopulationControlDLC Region 1_Obj4|ME_PlayerObjectivePopulationControl");
    vars.targetNameLabels.Add("obj_dlc_name_me_playerobjectivepopulationcontroldlc_obj4", "ME_PlayerObjectivePopulationControlDLC Region 1_Obj4");
    settings.Add("obj_dlc_name_me_huntobjectivedlc_obj5", false, "DLC - Chidori Island - Electric Mayhem / Destroy the Target", "region_dlc_chidori");
    vars.targetNames.Add("obj_dlc_name_me_huntobjectivedlc_obj5", "ME_HuntObjectiveDLC Region 1_Obj5|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_dlc_name_me_huntobjectivedlc_obj5", "ME_HuntObjectiveDLC Region 1_Obj5");
    settings.Add("obj_dlc_name_me_playerobjectiveterrorizedlc_obj6", false, "DLC - Chidori Island - Sailor Trash / Consume 10 Sailors", "region_dlc_chidori");
    vars.targetNames.Add("obj_dlc_name_me_playerobjectiveterrorizedlc_obj6", "ME_PlayerObjectiveTerrorizeDLC Region 1_Obj6|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_dlc_name_me_playerobjectiveterrorizedlc_obj6", "ME_PlayerObjectiveTerrorizeDLC Region 1_Obj6");
    settings.Add("obj_dlc_name_me_playerobjectivepopulationcontroldlc_obj7", false, "DLC - Chidori Island - The Other, Other White Meat / Kill 5 Great Whites", "region_dlc_chidori");
    vars.targetNames.Add("obj_dlc_name_me_playerobjectivepopulationcontroldlc_obj7", "ME_PlayerObjectivePopulationControlDLC Region 1_Obj7|ME_PlayerObjectivePopulationControl");
    vars.targetNameLabels.Add("obj_dlc_name_me_playerobjectivepopulationcontroldlc_obj7", "ME_PlayerObjectivePopulationControlDLC Region 1_Obj7");
    settings.Add("obj_dlc_name_me_huntobjectivedlc_obj8", false, "DLC - Chidori Island - Drop Shadow / Destroy the Target", "region_dlc_chidori");
    vars.targetNames.Add("obj_dlc_name_me_huntobjectivedlc_obj8", "ME_HuntObjectiveDLC Region 1_Obj8|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_dlc_name_me_huntobjectivedlc_obj8", "ME_HuntObjectiveDLC Region 1_Obj8");
    settings.Add("obj_dlc_name_me_playerobjectiveterrorizedlc_obj9", false, "DLC - Chidori Island - Biscuits and Navy / Consume 10 Sailors", "region_dlc_chidori");
    vars.targetNames.Add("obj_dlc_name_me_playerobjectiveterrorizedlc_obj9", "ME_PlayerObjectiveTerrorizeDLC Region 1_Obj9|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_dlc_name_me_playerobjectiveterrorizedlc_obj9", "ME_PlayerObjectiveTerrorizeDLC Region 1_Obj9");
    settings.Add("obj_dlc_guid_power_trip", false, "DLC - Chidori Island - Power Trip / Destroy the Power Node!", "region_dlc_chidori");
    vars.targetGuids["obj_dlc_guid_power_trip"] = new uint[] { 0x85A35495u, 0x4E861538u, 0x660DEEA6u, 0xC127DE32u };
    vars.targetOrder.Add("obj_dlc_guid_power_trip");
    settings.Add("obj_dlc_guid_cut_to_the_chase", false, "DLC - Chidori Island - Cut to the Chase / Swim through the rings.", "region_dlc_chidori");
    vars.targetGuids["obj_dlc_guid_cut_to_the_chase"] = new uint[] { 0x5B438883u, 0x4851927Bu, 0xCFC0468Eu, 0x4F4AE506u };
    vars.targetOrder.Add("obj_dlc_guid_cut_to_the_chase");
    settings.Add("obj_dlc_guid_concealed_weapon", false, "DLC - Chidori Island - Concealed Weapon / Check in on the NWO", "region_dlc_chidori");
    vars.targetGuids["obj_dlc_guid_concealed_weapon"] = new uint[] { 0xBE8B66F5u, 0x4DDEDD44u, 0x08E133BCu, 0xEC148F28u };
    vars.targetOrder.Add("obj_dlc_guid_concealed_weapon");
    settings.Add("obj_dlc_name_me_huntobjectivedlc_obj13", false, "DLC - Chidori Island - Mind Your Bone Business / Destroy the Target", "region_dlc_chidori");
    vars.targetNames.Add("obj_dlc_name_me_huntobjectivedlc_obj13", "ME_HuntObjectiveDLC Region 1_Obj13|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_dlc_name_me_huntobjectivedlc_obj13", "ME_HuntObjectiveDLC Region 1_Obj13");
    settings.Add("obj_dlc_name_me_playerobjectiveterrorizedlc_obj14", false, "DLC - Chidori Island - Naval Grazing / Consume 10 Sailors", "region_dlc_chidori");
    vars.targetNames.Add("obj_dlc_name_me_playerobjectiveterrorizedlc_obj14", "ME_PlayerObjectiveTerrorizeDLC Region 1_Obj14|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_dlc_name_me_playerobjectiveterrorizedlc_obj14", "ME_PlayerObjectiveTerrorizeDLC Region 1_Obj14");
    settings.Add("obj_dlc_guid_terrornova", false, "DLC - Chidori Island - Terrornova / Reach Bounty Rank 5", "region_dlc_chidori");
    vars.targetGuids["obj_dlc_guid_terrornova"] = new uint[] { 0x5F55B761u, 0x41DB031Eu, 0xCAD63398u, 0x8F6A66AFu };
    vars.targetOrder.Add("obj_dlc_guid_terrornova");
    settings.Add("obj_dlc_name_me_playerobjectivelandmarkdlc_obj16", false, "DLC - Chidori Island - The Plover Island Landmarks / Discover all Landmarks", "region_dlc_chidori");
    vars.targetNames.Add("obj_dlc_name_me_playerobjectivelandmarkdlc_obj16", "ME_PlayerObjectiveLandmarkDLC Region 1_Obj16|ME_PlayerObjectiveLandmark");
    vars.targetNameLabels.Add("obj_dlc_name_me_playerobjectivelandmarkdlc_obj16", "ME_PlayerObjectiveLandmarkDLC Region 1_Obj16");
    settings.Add("obj_dlc_name_me_playerobjectivecollectabledlc_obj17", false, "DLC - Chidori Island - Plate Lunch / Collect all License Plates", "region_dlc_chidori");
    vars.targetNames.Add("obj_dlc_name_me_playerobjectivecollectabledlc_obj17", "ME_PlayerObjectiveCollectableDLC Region 1_Obj17|ME_PlayerObjectiveCollectable");
    vars.targetNameLabels.Add("obj_dlc_name_me_playerobjectivecollectabledlc_obj17", "ME_PlayerObjectiveCollectableDLC Region 1_Obj17");
    settings.Add("obj_dlc_name_me_playerobjectivenutrientcachedlc_obj18", false, "DLC - Chidori Island - Plover Island Nutrient Caches / Collect all Caches", "region_dlc_chidori");
    vars.targetNames.Add("obj_dlc_name_me_playerobjectivenutrientcachedlc_obj18", "ME_PlayerObjectiveNutrientCacheDLC Region 1_Obj18|ME_PlayerObjectiveNutrientCache");
    vars.targetNameLabels.Add("obj_dlc_name_me_playerobjectivenutrientcachedlc_obj18", "ME_PlayerObjectiveNutrientCacheDLC Region 1_Obj18");
    settings.Add("obj_dlc_name_me_huntobjectivedlc_obj19", false, "DLC - Chidori Island - Let Me Clear My Boat / Destroy the Target", "region_dlc_chidori");
    vars.targetNames.Add("obj_dlc_name_me_huntobjectivedlc_obj19", "ME_HuntObjectiveDLC Region 1_Obj19|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_dlc_name_me_huntobjectivedlc_obj19", "ME_HuntObjectiveDLC Region 1_Obj19");
    settings.Add("obj_dlc_name_me_huntobjectivedlc_obj20", false, "DLC - Chidori Island - Choose Your Bone Adventure / Destroy the Target", "region_dlc_chidori");
    vars.targetNames.Add("obj_dlc_name_me_huntobjectivedlc_obj20", "ME_HuntObjectiveDLC Region 1_Obj20|ME_HuntObjective");
    vars.targetNameLabels.Add("obj_dlc_name_me_huntobjectivedlc_obj20", "ME_HuntObjectiveDLC Region 1_Obj20");
    settings.Add("obj_dlc_name_me_playerobjectiveterrorizedlc_obj21", false, "DLC - Chidori Island - NWOh-No / Consume 10 Sailors", "region_dlc_chidori");
    vars.targetNames.Add("obj_dlc_name_me_playerobjectiveterrorizedlc_obj21", "ME_PlayerObjectiveTerrorizeDLC Region 1_Obj21|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_dlc_name_me_playerobjectiveterrorizedlc_obj21", "ME_PlayerObjectiveTerrorizeDLC Region 1_Obj21");
    settings.Add("obj_dlc_name_me_playerobjectiveterrorizedlc_obj22", false, "DLC - Chidori Island - Naval Piercing / Consume 10 Sailors", "region_dlc_chidori");
    vars.targetNames.Add("obj_dlc_name_me_playerobjectiveterrorizedlc_obj22", "ME_PlayerObjectiveTerrorizeDLC Region 1_Obj22|ME_PlayerObjectiveTerrorize");
    vars.targetNameLabels.Add("obj_dlc_name_me_playerobjectiveterrorizedlc_obj22", "ME_PlayerObjectiveTerrorizeDLC Region 1_Obj22");
    settings.Add("obj_dlc_guid_time_trial_dive_bomber", false, "DLC - Chidori Island - Time Trial: Dive Bomber / Swim through the rings.", "region_dlc_chidori");
    vars.targetGuids["obj_dlc_guid_time_trial_dive_bomber"] = new uint[] { 0x5A984A1Cu, 0x4EDDE83Bu, 0xD907CB97u, 0x13D2B2D2u };
    vars.targetOrder.Add("obj_dlc_guid_time_trial_dive_bomber");
    settings.Add("obj_dlc_guid_time_trial_wet_wipe", false, "DLC - Chidori Island - Time Trial: Wet Wipe / Swim through the rings.", "region_dlc_chidori");
    vars.targetGuids["obj_dlc_guid_time_trial_wet_wipe"] = new uint[] { 0x5BD312C6u, 0x405087DFu, 0x9CA9AAAAu, 0x5B29DF35u };
    vars.targetOrder.Add("obj_dlc_guid_time_trial_wet_wipe");
    settings.Add("obj_dlc_name_med_playerobjective_tinfoilhatdlc_obj25", false, "DLC - Chidori Island - Plover Island Quester Collector / Find All Questers", "region_dlc_chidori");
    vars.targetNames.Add("obj_dlc_name_med_playerobjective_tinfoilhatdlc_obj25", "MED_PlayerObjective_TinFoilHatDLC Region 1_Obj25|MED_PlayerObjective_TinFoilHat");
    vars.targetNameLabels.Add("obj_dlc_name_med_playerobjective_tinfoilhatdlc_obj25", "MED_PlayerObjective_TinFoilHatDLC Region 1_Obj25");
    settings.Add("obj_dlc_name_me_playerobjectivegratesdlc_obj26", false, "DLC - Chidori Island - Plover Island Grates", "region_dlc_chidori");
    vars.targetNames.Add("obj_dlc_name_me_playerobjectivegratesdlc_obj26", "ME_PlayerObjectiveGratesDLC Region 1_Obj26|ME_PlayerObjectiveGrates");
    vars.targetNameLabels.Add("obj_dlc_name_me_playerobjectivegratesdlc_obj26", "ME_PlayerObjectiveGratesDLC Region 1_Obj26");

    /*
        To add another objective split, add another block like this in startup.

        vars.AddObjectiveSplit(
            "obj_example",
            true,
            "Example Quest Name",
            0xAABBCCDDu,
            0x11223344u,
            0x55667788u,
            0x99AABBCCu
        );
    */
}

init
{
    

    if (modules.First().ModuleMemorySize == 0x1E31B000)
    {
        
        version = "Epic";
    }
    else if (modules.First().ModuleMemorySize == 0x1E1C8000)
    {
        
        version = "Steam";
    }
    else
    {
        
        version = "Epic";
    }

    Func<string, int, IntPtr> OffsetSignatureScan = (string Signature, int OffsetPosition) => {
        var Scanner = new SignatureScanner(game, modules.First().BaseAddress, modules.First().ModuleMemorySize);
        IntPtr Pointer = Scanner.Scan(new SigScanTarget(Signature));
        if (Pointer != IntPtr.Zero)
        {
            var Offset = memory.ReadValue<int>(new IntPtr(Pointer.ToInt64() + OffsetPosition));
            Pointer = new IntPtr(Pointer.ToInt64() + Offset + OffsetPosition + sizeof(int));
        }
        return Pointer;
    };

    IntPtr GNames = OffsetSignatureScan(
        "48 8D 0D ?? ?? ?? ?? E8 ?? ?? ?? ?? C6 05 ?? ?? ?? ?? 01 0F 10 03 4C 8D 44 24 20 48 8B C8",
        3
    );

    

    vars.GNames = GNames;
    vars.Names = new Dictionary<int, string>();
    vars.NamesInitialized = false;

    Func<Dictionary<int, string>> DumpNames = () => {
        int FNameStride = 2;
        int FNameDataOffset = 2;
        int FNameMaxBlockBits = 13;
        int FNameBlockOffsetBits = 16;
        int FNameBlockOffsets = 1 << FNameBlockOffsetBits;
        int FNameBlockSize = FNameStride * FNameBlockOffsets;

        var Names = new Dictionary<int, string>();

        Action<int,int> DumpBlock = (int BlockIndex, int BlockSize) => {
            IntPtr BlockPtr = memory.ReadPointer(new IntPtr(GNames.ToInt64() + 16 + BlockIndex * 8));
            var BlockEnd = BlockPtr.ToInt64() + BlockSize - FNameDataOffset;
            int Offset = 0;

            while (BlockPtr.ToInt64() < BlockEnd)
            {
                var Header = memory.ReadValue<short>(BlockPtr);
                var IsWide = (Header & 1) == 1;
                var Length = (Header >> 6);

                if (Length == 0)
                {
                    break;
                }

                var NameSize = Length * (IsWide ? 2 : 1);
                var Value = memory.ReadString(new IntPtr(BlockPtr.ToInt64() + FNameDataOffset), IsWide ? ReadStringType.UTF16 : ReadStringType.UTF8, NameSize);
                var EntrySize = (FNameDataOffset + NameSize + FNameStride - 1) & ~(FNameStride - 1);

                BlockPtr = new IntPtr(BlockPtr.ToInt64() + EntrySize);

                var Handle = BlockIndex << FNameBlockOffsetBits | Offset;
                Offset += EntrySize / FNameStride;

                if (!Names.ContainsKey(Handle))
                {
                    Names.Add(Handle, Value);
                }
            }
        };

        var CurrentBlock = memory.ReadValue<int>(new IntPtr(GNames.ToInt64() + 0x8));
        var CurrentByteCursor = memory.ReadValue<int>(new IntPtr(GNames.ToInt64() + 0xC));

        for (int BlockIndex = 0; BlockIndex < CurrentBlock; ++BlockIndex)
        {
            DumpBlock(BlockIndex, FNameBlockSize);
        }

        DumpBlock(CurrentBlock, CurrentByteCursor);

        return Names;
    };

    vars.DumpNames = DumpNames;

    vars.completedObjectivesDataPtr = new DeepPointer(
        "Maneater-Win64-Shipping.exe",
        0x0486F1D0,
        0x128,
        0x660,
        0x130,
        0x20,
        0x378
    );

    vars.completedObjectivesNumPtr = new DeepPointer(
        "Maneater-Win64-Shipping.exe",
        0x0486F1D0,
        0x128,
        0x660,
        0x130,
        0x20,
        0x380
    );

    vars.completedObjectivesMaxPtr = new DeepPointer(
        "Maneater-Win64-Shipping.exe",
        0x0486F1D0,
        0x128,
        0x660,
        0x130,
        0x20,
        0x384
    );

    vars.activeStoryIndexPtr = new DeepPointer(
        "Maneater-Win64-Shipping.exe",
        0x0486F1D0,
        0x128,
        0x660,
        0x130,
        0x20,
        0x3A8
    );

    vars.storyConditionsCompletePtr = new DeepPointer(
        "Maneater-Win64-Shipping.exe",
        0x0486F1D0,
        0x128,
        0x660,
        0x130,
        0x20,
        0x3AC
    );

    vars.storyEventConditionsCompletePtr = new DeepPointer(
        "Maneater-Win64-Shipping.exe",
        0x0486F1D0,
        0x128,
        0x660,
        0x130,
        0x20,
        0x3AC
    );

    vars.playerLevelPtr = new DeepPointer(
        "Maneater-Win64-Shipping.exe",
        0x04AE7120,
        0x0,
        0x10,
        0xB8,
        0x228,
        0x3C0
    );

    vars.currentGrowthStagePtr = new DeepPointer(
        "Maneater-Win64-Shipping.exe",
        0x04AE7120,
        0x0,
        0x10,
        0xB8,
        0x228,
        0x3C4
    );

    vars.playerSharkStatePtr = new DeepPointer("Maneater-Win64-Shipping.exe", 0x04AE7120, 0x0, 0x10, 0xB8, 0x228);
    vars.playerCurrentProteinReservePtr = new DeepPointer("Maneater-Win64-Shipping.exe", 0x04AE7120, 0x0, 0x10, 0xB8, 0x228, 0x388);
    vars.playerCurrentFatReservePtr = new DeepPointer("Maneater-Win64-Shipping.exe", 0x04AE7120, 0x0, 0x10, 0xB8, 0x228, 0x38C);
    vars.playerCurrentMineralReservePtr = new DeepPointer("Maneater-Win64-Shipping.exe", 0x04AE7120, 0x0, 0x10, 0xB8, 0x228, 0x390);
    vars.playerCurrentMutagenReservePtr = new DeepPointer("Maneater-Win64-Shipping.exe", 0x04AE7120, 0x0, 0x10, 0xB8, 0x228, 0x394);
    vars.playerCurrentExpAmountPtr = new DeepPointer("Maneater-Win64-Shipping.exe", 0x04AE7120, 0x0, 0x10, 0xB8, 0x228, 0x398);
    vars.playerCurrentPlayerLevelPtr = new DeepPointer("Maneater-Win64-Shipping.exe", 0x04AE7120, 0x0, 0x10, 0xB8, 0x228, 0x39C);
    vars.playerCumulativeXPGainedFromObjectivesPtr = new DeepPointer("Maneater-Win64-Shipping.exe", 0x04AE7120, 0x0, 0x10, 0xB8, 0x228, 0x3A0);
    vars.playerCumulativeXPGainedFromBountiesPtr = new DeepPointer("Maneater-Win64-Shipping.exe", 0x04AE7120, 0x0, 0x10, 0xB8, 0x228, 0x3A4);
    vars.playerCumulativeXPGainedFromEatingPtr = new DeepPointer("Maneater-Win64-Shipping.exe", 0x04AE7120, 0x0, 0x10, 0xB8, 0x228, 0x3A8);
    vars.playerCumulativeXPGainedFromLandmarksPtr = new DeepPointer("Maneater-Win64-Shipping.exe", 0x04AE7120, 0x0, 0x10, 0xB8, 0x228, 0x3AC);
    vars.playerCumulativeXPGainedFromCachesPtr = new DeepPointer("Maneater-Win64-Shipping.exe", 0x04AE7120, 0x0, 0x10, 0xB8, 0x228, 0x3B0);
    vars.playerCumulativeXPGainedFromCollectablesPtr = new DeepPointer("Maneater-Win64-Shipping.exe", 0x04AE7120, 0x0, 0x10, 0xB8, 0x228, 0x3B4);
    vars.playerCumulativeXPGainedFromCheatsPtr = new DeepPointer("Maneater-Win64-Shipping.exe", 0x04AE7120, 0x0, 0x10, 0xB8, 0x228, 0x3B8);
    vars.playerGrowthStageBehindTheScenesLevelPtr = new DeepPointer("Maneater-Win64-Shipping.exe", 0x04AE7120, 0x0, 0x10, 0xB8, 0x228, 0x3BC);
    vars.playerTheoreticalPlayerLevelPtr = new DeepPointer("Maneater-Win64-Shipping.exe", 0x04AE7120, 0x0, 0x10, 0xB8, 0x228, 0x3C0);
    vars.playerCurrentGrowthStagePtr = new DeepPointer("Maneater-Win64-Shipping.exe", 0x04AE7120, 0x0, 0x10, 0xB8, 0x228, 0x3C4);
    vars.bountyManagerPtr = new DeepPointer("Maneater-Win64-Shipping.exe", 0x0486F1D0, 0x498, 0x28, 0x8, 0xF0, 0x5D8);
    vars.currentBountyManagerPtr = new DeepPointer("Maneater-Win64-Shipping.exe", 0x0486F1D0, 0x498, 0x28, 0x8, 0xF0, 0x5D8);
    vars.infamyLevelPtr = new DeepPointer("Maneater-Win64-Shipping.exe", 0x0486F1D0, 0x498, 0x28, 0x8, 0xF0, 0x5D8, 0x394);
    vars.currentInfamyLevelPtr = new DeepPointer("Maneater-Win64-Shipping.exe", 0x0486F1D0, 0x498, 0x28, 0x8, 0xF0, 0x5D8, 0x394);
    vars.infamyPointsPtr = new DeepPointer("Maneater-Win64-Shipping.exe", 0x0486F1D0, 0x498, 0x28, 0x8, 0xF0, 0x5D8, 0x3A0);
    vars.lastBossLevelDefeatedPtr = new DeepPointer("Maneater-Win64-Shipping.exe", 0x0486F1D0, 0x498, 0x28, 0x8, 0xF0, 0x5D8, 0x3A4);

    vars.prevCompletedObjectiveGuids = new HashSet<string>();
    vars.completedObjectiveGuids = new HashSet<string>();
    vars.prevCompletedObjectiveNameKeys = new HashSet<string>();
    vars.completedObjectiveNameKeys = new HashSet<string>();
    vars.lastReadCompletedObjectiveNameKeys = new HashSet<string>();
    vars.splittedObjectives = new HashSet<string>();
    vars.splittedStoryState = new HashSet<string>();
    vars.splittedPlayerState = new HashSet<string>();
    vars.splittedBountyState = new HashSet<string>();
    vars.pendingStorySplits = new HashSet<string>();
    vars.pendingObjectiveSplits = new HashSet<string>();
    vars.pendingPlayerLevelSplits = new HashSet<string>();
    vars.pendingPlayerXPSplits = new HashSet<string>();
    vars.pendingInfamySplits = new HashSet<string>();
    vars.pendingDlcInfamySplits = new HashSet<string>();
    vars.hasObjectiveBaseline = false;
    vars.hasStoryStateBaseline = false;
    vars.hasPlayerStateBaseline = false;
    vars.hasBountyStateBaseline = false;
    vars.canSplitObjectivesThisFrame = false;
    vars.canSplitStoryStateThisFrame = false;
    vars.canSplitPlayerStateThisFrame = false;
    vars.canLevelSplit = false;
    vars.playerStateBaselineDelayFrames = 1;
    vars.canSplitBountyStateThisFrame = false;
    vars.hadValidObjectiveRead = false;
    vars.hadValidStoryStateRead = false;
    vars.hadValidPlayerStateRead = false;
    vars.hadValidBountyStateRead = false;
    vars.suppressSplitThisUpdate = false;
    vars.wasLoading = false;
    vars.justFinishedLoadingFrames = 0;
    vars.lastLoggedCompletedNum = -1;
    vars.lastLoggedGuidDump = "";
    vars.lastObjectiveReadFailReason = "";
    vars.playerStateReadFailReason = "";
    vars.lastPlayerStateReadFailReason = "";
    vars.bountyStateReadFailReason = "";
    vars.lastBountyStateReadFailReason = "";
    vars.debugObjectiveFrameCounter = 0;
    vars.debugStoryFrameCounter = 0;
    vars.debugTutorialFrameCounter = 0;
    vars.debugBountyFrameCounter = 0;
    vars.lastLoggedPlayerState = "";
    vars.lastLoggedStoryState = "";
    vars.lastLoggedTutorialState = "";
    vars.lastLoggedBountyState = "";
    vars.lastLoggedPointerIdentity = "";
    vars.debugPointerIdentityFrameCounter = 0;
    vars.lastCompletedObjectivesData = IntPtr.Zero;
    vars.previousCompletedObjectivesNum = 0;
    vars.lastCompletedObjectivesNum = 0;
    vars.lastCompletedObjectivesMax = 0;
    vars.lastCompletedObjectiveName = "";
    vars.lastCompletedObjectiveGuid = "";
    vars.currentCompletedObjectiveDebugRows = new List<string>();
    vars.activeStoryIndex = 0;
    vars.prevActiveStoryIndex = 0;
    vars.readActiveStoryIndex = 0;
    vars.storyEventConditionsComplete = 0;
    vars.prevStoryEventConditionsComplete = 0;
    vars.readStoryEventConditionsComplete = 0;
    vars.hadStoryIndexBeforeLoad = false;
    vars.storyIndexBeforeLoad = 0;
    vars.storyConditionsBeforeLoad = 0;
    vars.completedObjectivesNumIncreaseRecentFrames = 0;
    vars.storyStateReadFailed = false;
    vars.tutorialObjectiveFound = false;
    vars.tutorialComplete = false;
    vars.pendingLevel1SplitOnTutorialComplete = false;
    vars.tutorialStateF0 = -1;
    vars.tutorialType79 = -1;
    vars.tutorialFlagF1 = -1;
    vars.readTutorialObjectiveFound = false;
    vars.readTutorialComplete = false;
    vars.readTutorialStateF0 = -1;
    vars.readTutorialType79 = -1;
    vars.readTutorialFlagF1 = -1;

    vars.splittedObjectives.Clear();
    vars.splittedStoryState = new HashSet<string>();
    vars.splittedPlayerState.Clear();
    vars.splittedBountyState.Clear();
    vars.pendingStorySplits.Clear();
    vars.pendingObjectiveSplits.Clear();
    vars.pendingPlayerLevelSplits.Clear();
    vars.pendingPlayerXPSplits.Clear();
    vars.pendingInfamySplits.Clear();
    vars.pendingDlcInfamySplits.Clear();
    vars.prevCompletedObjectiveGuids.Clear();
    vars.completedObjectiveGuids.Clear();
    vars.prevCompletedObjectiveNameKeys.Clear();
    vars.completedObjectiveNameKeys.Clear();
    vars.lastReadCompletedObjectiveNameKeys.Clear();

    vars.prevPlayerCurrentProteinReserve = 0;
    vars.prevPlayerCurrentFatReserve = 0;
    vars.prevPlayerCurrentMineralReserve = 0;
    vars.prevPlayerCurrentMutagenReserve = 0;
    vars.prevPlayerCurrentExpAmount = 0;
    vars.prevPlayerCurrentPlayerLevel = 0;
    vars.prevPlayerTheoreticalPlayerLevel = 0;
    vars.prevPlayerCurrentGrowthStage = 0;

    vars.playerCurrentProteinReserve = 0;
    vars.playerCurrentFatReserve = 0;
    vars.playerCurrentMineralReserve = 0;
    vars.playerCurrentMutagenReserve = 0;
    vars.playerCurrentExpAmount = 0;
    vars.playerCurrentPlayerLevel = 0;
    vars.playerCumulativeXPGainedFromObjectives = 0;
    vars.playerCumulativeXPGainedFromBounties = 0;
    vars.playerCumulativeXPGainedFromEating = 0;
    vars.playerCumulativeXPGainedFromLandmarks = 0;
    vars.playerCumulativeXPGainedFromCaches = 0;
    vars.playerCumulativeXPGainedFromCollectables = 0;
    vars.playerCumulativeXPGainedFromCheats = 0;
    vars.playerGrowthStageBehindTheScenesLevel = 0;
    vars.playerTheoreticalPlayerLevel = 0;
    vars.playerCurrentGrowthStage = 0;
    vars.isGameplayWorld = false;
    vars.isNonGameplayWorld = true;
    vars.readIsGameplayWorld = false;
    vars.readIsNonGameplayWorld = true;
    vars.gameplayWorldName = "";
    vars.readGameplayWorldName = "";
    vars.gameplayWorldPtr = IntPtr.Zero;
    vars.readGameplayWorldPtr = IntPtr.Zero;
    vars.wasGameplayWorld = false;
    vars.lastLoggedGameplayWorldState = "";
    vars.lastLoggedDebugSettings = "";
    vars.lastLoggedUpdatePath = "";
    vars.debugUpdatePathFrameCounter = 0;

    vars.readPlayerCurrentProteinReserve = 0;
    vars.readPlayerCurrentFatReserve = 0;
    vars.readPlayerCurrentMineralReserve = 0;
    vars.readPlayerCurrentMutagenReserve = 0;
    vars.readPlayerCurrentExpAmount = 0;
    vars.readPlayerCurrentPlayerLevel = 0;
    vars.readPlayerCumulativeXPGainedFromObjectives = 0;
    vars.readPlayerCumulativeXPGainedFromBounties = 0;
    vars.readPlayerCumulativeXPGainedFromEating = 0;
    vars.readPlayerCumulativeXPGainedFromLandmarks = 0;
    vars.readPlayerCumulativeXPGainedFromCaches = 0;
    vars.readPlayerCumulativeXPGainedFromCollectables = 0;
    vars.readPlayerCumulativeXPGainedFromCheats = 0;
    vars.readPlayerGrowthStageBehindTheScenesLevel = 0;
    vars.readPlayerTheoreticalPlayerLevel = 0;
    vars.readPlayerCurrentGrowthStage = 0;
    vars.readPlayerSharkStatePtr = IntPtr.Zero;
    vars.playerStateLastValid = false;

    vars.prevInfamyLevel = 0;
    vars.prevInfamyPoints = 0;
    vars.prevLastBossLevelDefeated = 0;
    vars.prevBountyWorldName = "";
    vars.prevIsBaseGameWorld = false;
    vars.prevIsDlcWorld = false;
    vars.infamyLevel = 0;
    vars.infamyPoints = 0;
    vars.lastBossLevelDefeated = 0;
    vars.currentBountyManager = IntPtr.Zero;
    vars.bountyWorldName = "";
    vars.isBaseGameWorld = false;
    vars.isDlcWorld = false;
    vars.readInfamyLevel = 0;
    vars.readInfamyPoints = 0;
    vars.readLastBossLevelDefeated = 0;
    vars.readCurrentBountyManager = IntPtr.Zero;
    vars.readBountyWorldName = "";
    vars.readIsBaseGameWorld = false;
    vars.readIsDlcWorld = false;

    vars.ReadPlayerSharkState = (Func<Process, bool>)((proc) =>
    {
        IntPtr chainPtr = IntPtr.Zero;
        IntPtr statePtr = IntPtr.Zero;
        vars.playerStateLastValid = false;
        vars.readPlayerCurrentProteinReserve = 0;
        vars.readPlayerCurrentFatReserve = 0;
        vars.readPlayerCurrentMineralReserve = 0;
        vars.readPlayerCurrentMutagenReserve = 0;
        vars.readPlayerCurrentExpAmount = 0;
        vars.readPlayerCurrentPlayerLevel = 0;
        vars.readPlayerCumulativeXPGainedFromObjectives = 0;
        vars.readPlayerCumulativeXPGainedFromBounties = 0;
        vars.readPlayerCumulativeXPGainedFromEating = 0;
        vars.readPlayerCumulativeXPGainedFromLandmarks = 0;
        vars.readPlayerCumulativeXPGainedFromCaches = 0;
        vars.readPlayerCumulativeXPGainedFromCollectables = 0;
        vars.readPlayerCumulativeXPGainedFromCheats = 0;
        vars.readPlayerGrowthStageBehindTheScenesLevel = 0;
        vars.readPlayerTheoreticalPlayerLevel = 0;
        vars.readPlayerCurrentGrowthStage = 0;

        Func<IntPtr, bool> TryReadPlayerStateAt = (candidatePtr) =>
        {
            if (candidatePtr == IntPtr.Zero)
            {
                return false;
            }

            try
            {
                vars.readPlayerCurrentProteinReserve = memory.ReadValue<int>(new IntPtr(candidatePtr.ToInt64() + 0x388));
                vars.readPlayerCurrentFatReserve = memory.ReadValue<int>(new IntPtr(candidatePtr.ToInt64() + 0x38C));
                vars.readPlayerCurrentMineralReserve = memory.ReadValue<int>(new IntPtr(candidatePtr.ToInt64() + 0x390));
                vars.readPlayerCurrentMutagenReserve = memory.ReadValue<int>(new IntPtr(candidatePtr.ToInt64() + 0x394));
                vars.readPlayerCurrentExpAmount = memory.ReadValue<int>(new IntPtr(candidatePtr.ToInt64() + 0x398));
                vars.readPlayerCurrentPlayerLevel = memory.ReadValue<int>(new IntPtr(candidatePtr.ToInt64() + 0x39C));
                vars.readPlayerCumulativeXPGainedFromObjectives = memory.ReadValue<int>(new IntPtr(candidatePtr.ToInt64() + 0x3A0));
                vars.readPlayerCumulativeXPGainedFromBounties = memory.ReadValue<int>(new IntPtr(candidatePtr.ToInt64() + 0x3A4));
                vars.readPlayerCumulativeXPGainedFromEating = memory.ReadValue<int>(new IntPtr(candidatePtr.ToInt64() + 0x3A8));
                vars.readPlayerCumulativeXPGainedFromLandmarks = memory.ReadValue<int>(new IntPtr(candidatePtr.ToInt64() + 0x3AC));
                vars.readPlayerCumulativeXPGainedFromCaches = memory.ReadValue<int>(new IntPtr(candidatePtr.ToInt64() + 0x3B0));
                vars.readPlayerCumulativeXPGainedFromCollectables = memory.ReadValue<int>(new IntPtr(candidatePtr.ToInt64() + 0x3B4));
                vars.readPlayerCumulativeXPGainedFromCheats = memory.ReadValue<int>(new IntPtr(candidatePtr.ToInt64() + 0x3B8));
                vars.readPlayerGrowthStageBehindTheScenesLevel = memory.ReadValue<int>(new IntPtr(candidatePtr.ToInt64() + 0x3BC));
                vars.readPlayerTheoreticalPlayerLevel = memory.ReadValue<int>(new IntPtr(candidatePtr.ToInt64() + 0x3C0));
                vars.readPlayerCurrentGrowthStage = memory.ReadValue<int>(new IntPtr(candidatePtr.ToInt64() + 0x3C4));
            }
            catch
            {
                return false;
            }

            return
                vars.readPlayerCurrentPlayerLevel >= 1 &&
                vars.readPlayerCurrentPlayerLevel <= 40 &&
                vars.readPlayerTheoreticalPlayerLevel >= 1 &&
                vars.readPlayerTheoreticalPlayerLevel <= 40 &&
                vars.readPlayerCurrentGrowthStage >= 1 &&
                vars.readPlayerCurrentGrowthStage <= 5 &&
                vars.readPlayerCurrentExpAmount >= 0 &&
                vars.readPlayerCurrentExpAmount <= 10000000;
        };

        try
        {
            IntPtr p0 = memory.ReadValue<IntPtr>(new IntPtr(modules.First().BaseAddress.ToInt64() + 0x04AE7120));
            IntPtr p1 = memory.ReadValue<IntPtr>(new IntPtr(p0.ToInt64() + 0x0));
            IntPtr p2 = memory.ReadValue<IntPtr>(new IntPtr(p1.ToInt64() + 0x10));
            IntPtr p3 = memory.ReadValue<IntPtr>(new IntPtr(p2.ToInt64() + 0xB8));
            chainPtr = memory.ReadValue<IntPtr>(new IntPtr(p3.ToInt64() + 0x228));
        }
        catch
        {
            chainPtr = IntPtr.Zero;
        }

        vars.readPlayerSharkStatePtr = chainPtr;

        if (TryReadPlayerStateAt(chainPtr))
        {
            statePtr = chainPtr;
        }
        else
        {
            try
            {
                IntPtr stateFromShark = memory.ReadValue<IntPtr>(new IntPtr(chainPtr.ToInt64() + 0x1FC8));
                if (TryReadPlayerStateAt(stateFromShark))
                {
                    statePtr = stateFromShark;
                }
            }
            catch
            {
            }
        }

        vars.readPlayerSharkStatePtr = statePtr;

        bool valid =
            statePtr != IntPtr.Zero &&
            vars.readPlayerCurrentPlayerLevel >= 1 &&
            vars.readPlayerCurrentPlayerLevel <= 40 &&
            vars.readPlayerTheoreticalPlayerLevel >= 1 &&
            vars.readPlayerTheoreticalPlayerLevel <= 40 &&
            vars.readPlayerCurrentGrowthStage >= 1 &&
            vars.readPlayerCurrentGrowthStage <= 5 &&
            vars.readPlayerCurrentExpAmount >= 0 &&
            vars.readPlayerCurrentExpAmount <= 10000000;

        if (!valid)
        {
            vars.playerStateReadFailReason =
                "InvalidValues:" +
                " level=" + vars.readPlayerCurrentPlayerLevel +
                " theoreticalLevel=" + vars.readPlayerTheoreticalPlayerLevel +
                " exp=" + vars.readPlayerCurrentExpAmount +
                " growth=" + vars.readPlayerCurrentGrowthStage;
            return false;
        }

        vars.playerStateReadFailReason = "";
        vars.playerStateLastValid = true;
        return true;
    });

    vars.AbsorbPlayerSharkStateBaseline = (Action)(() =>
    {
        vars.prevPlayerCurrentProteinReserve = vars.readPlayerCurrentProteinReserve;
        vars.prevPlayerCurrentFatReserve = vars.readPlayerCurrentFatReserve;
        vars.prevPlayerCurrentMineralReserve = vars.readPlayerCurrentMineralReserve;
        vars.prevPlayerCurrentMutagenReserve = vars.readPlayerCurrentMutagenReserve;
        vars.prevPlayerCurrentExpAmount = vars.readPlayerCurrentExpAmount;
        vars.prevPlayerCurrentPlayerLevel = vars.readPlayerCurrentPlayerLevel;
        vars.prevPlayerTheoreticalPlayerLevel = vars.readPlayerTheoreticalPlayerLevel;
        vars.prevPlayerCurrentGrowthStage = vars.readPlayerCurrentGrowthStage;

        vars.playerCurrentProteinReserve = vars.readPlayerCurrentProteinReserve;
        vars.playerCurrentFatReserve = vars.readPlayerCurrentFatReserve;
        vars.playerCurrentMineralReserve = vars.readPlayerCurrentMineralReserve;
        vars.playerCurrentMutagenReserve = vars.readPlayerCurrentMutagenReserve;
        vars.playerCurrentExpAmount = vars.readPlayerCurrentExpAmount;
        vars.playerCurrentPlayerLevel = vars.readPlayerCurrentPlayerLevel;
        vars.playerCumulativeXPGainedFromObjectives = vars.readPlayerCumulativeXPGainedFromObjectives;
        vars.playerCumulativeXPGainedFromBounties = vars.readPlayerCumulativeXPGainedFromBounties;
        vars.playerCumulativeXPGainedFromEating = vars.readPlayerCumulativeXPGainedFromEating;
        vars.playerCumulativeXPGainedFromLandmarks = vars.readPlayerCumulativeXPGainedFromLandmarks;
        vars.playerCumulativeXPGainedFromCaches = vars.readPlayerCumulativeXPGainedFromCaches;
        vars.playerCumulativeXPGainedFromCollectables = vars.readPlayerCumulativeXPGainedFromCollectables;
        vars.playerCumulativeXPGainedFromCheats = vars.readPlayerCumulativeXPGainedFromCheats;
        vars.playerGrowthStageBehindTheScenesLevel = vars.readPlayerGrowthStageBehindTheScenesLevel;
        vars.playerTheoreticalPlayerLevel = vars.readPlayerTheoreticalPlayerLevel;
        vars.playerCurrentGrowthStage = vars.readPlayerCurrentGrowthStage;
        vars.hasPlayerStateBaseline = true;
        vars.hadValidPlayerStateRead = true;
    });

    vars.UpdatePlayerSharkState = (Action)(() =>
    {
        vars.prevPlayerCurrentProteinReserve = vars.playerCurrentProteinReserve;
        vars.prevPlayerCurrentFatReserve = vars.playerCurrentFatReserve;
        vars.prevPlayerCurrentMineralReserve = vars.playerCurrentMineralReserve;
        vars.prevPlayerCurrentMutagenReserve = vars.playerCurrentMutagenReserve;
        vars.prevPlayerCurrentExpAmount = vars.playerCurrentExpAmount;
        vars.prevPlayerCurrentPlayerLevel = vars.playerCurrentPlayerLevel;
        vars.prevPlayerTheoreticalPlayerLevel = vars.playerTheoreticalPlayerLevel;
        vars.prevPlayerCurrentGrowthStage = vars.playerCurrentGrowthStage;

        vars.playerCurrentProteinReserve = vars.readPlayerCurrentProteinReserve;
        vars.playerCurrentFatReserve = vars.readPlayerCurrentFatReserve;
        vars.playerCurrentMineralReserve = vars.readPlayerCurrentMineralReserve;
        vars.playerCurrentMutagenReserve = vars.readPlayerCurrentMutagenReserve;
        vars.playerCurrentExpAmount = vars.readPlayerCurrentExpAmount;
        vars.playerCurrentPlayerLevel = vars.readPlayerCurrentPlayerLevel;
        vars.playerCumulativeXPGainedFromObjectives = vars.readPlayerCumulativeXPGainedFromObjectives;
        vars.playerCumulativeXPGainedFromBounties = vars.readPlayerCumulativeXPGainedFromBounties;
        vars.playerCumulativeXPGainedFromEating = vars.readPlayerCumulativeXPGainedFromEating;
        vars.playerCumulativeXPGainedFromLandmarks = vars.readPlayerCumulativeXPGainedFromLandmarks;
        vars.playerCumulativeXPGainedFromCaches = vars.readPlayerCumulativeXPGainedFromCaches;
        vars.playerCumulativeXPGainedFromCollectables = vars.readPlayerCumulativeXPGainedFromCollectables;
        vars.playerCumulativeXPGainedFromCheats = vars.readPlayerCumulativeXPGainedFromCheats;
        vars.playerGrowthStageBehindTheScenesLevel = vars.readPlayerGrowthStageBehindTheScenesLevel;
        vars.playerTheoreticalPlayerLevel = vars.readPlayerTheoreticalPlayerLevel;
        vars.playerCurrentGrowthStage = vars.readPlayerCurrentGrowthStage;
        vars.hadValidPlayerStateRead = true;
    });

    vars.ReadBountyState = (Func<Process, bool>)((proc) =>
    {
        int value = 0;
        IntPtr bountyManager = IntPtr.Zero;

        if (!vars.currentBountyManagerPtr.Deref<IntPtr>(proc, out bountyManager)) { vars.bountyStateReadFailReason = "BountyManager"; return false; }
        if (bountyManager == IntPtr.Zero) { vars.bountyStateReadFailReason = "BountyManagerZero"; return false; }
        vars.readCurrentBountyManager = bountyManager;

        IntPtr persistentLevel = IntPtr.Zero;
        IntPtr world = IntPtr.Zero;

        try
        {
            persistentLevel = memory.ReadValue<IntPtr>(new IntPtr(bountyManager.ToInt64() + 0x20));
            if (persistentLevel == IntPtr.Zero) { vars.bountyStateReadFailReason = "PersistentLevelZero"; return false; }

            world = memory.ReadValue<IntPtr>(new IntPtr(persistentLevel.ToInt64() + 0x20));
            if (world == IntPtr.Zero) { vars.bountyStateReadFailReason = "WorldZero"; return false; }
        }
        catch
        {
            vars.bountyStateReadFailReason = "WorldOuterRead";
            return false;
        }

        string worldName = vars.ReadUObjectName(world);

        if (worldName == null)
        {
            vars.bountyStateReadFailReason = "WorldName";
            return false;
        }

        vars.readBountyWorldName = worldName;
        vars.readIsBaseGameWorld = worldName == "WorldMap_P";
        vars.readIsDlcWorld = worldName == "DLC_WorldMap_P";

        if (!vars.currentInfamyLevelPtr.Deref<int>(proc, out value)) { vars.bountyStateReadFailReason = "PlayerInfamyLevel"; return false; }
        vars.readInfamyLevel = value;
        if (!vars.infamyPointsPtr.Deref<int>(proc, out value)) { vars.bountyStateReadFailReason = "InfamyPointsEarned"; return false; }
        vars.readInfamyPoints = value;
        if (!vars.lastBossLevelDefeatedPtr.Deref<int>(proc, out value)) { vars.bountyStateReadFailReason = "LastBossLevelDefeated"; return false; }
        vars.readLastBossLevelDefeated = value;

        vars.bountyStateReadFailReason = "";
        return true;
    });

    vars.AbsorbBountyStateBaseline = (Action)(() =>
    {
        vars.prevInfamyLevel = vars.readInfamyLevel;
        vars.prevInfamyPoints = vars.readInfamyPoints;
        vars.prevLastBossLevelDefeated = vars.readLastBossLevelDefeated;
        vars.prevBountyWorldName = vars.readBountyWorldName;
        vars.prevIsBaseGameWorld = vars.readIsBaseGameWorld;
        vars.prevIsDlcWorld = vars.readIsDlcWorld;

        vars.infamyLevel = vars.readInfamyLevel;
        vars.infamyPoints = vars.readInfamyPoints;
        vars.lastBossLevelDefeated = vars.readLastBossLevelDefeated;
        vars.currentBountyManager = vars.readCurrentBountyManager;
        vars.bountyWorldName = vars.readBountyWorldName;
        vars.isBaseGameWorld = vars.readIsBaseGameWorld;
        vars.isDlcWorld = vars.readIsDlcWorld;

        vars.hasBountyStateBaseline = true;
        vars.hadValidBountyStateRead = true;
    });

    vars.UpdateBountyState = (Action)(() =>
    {
        vars.prevInfamyLevel = vars.infamyLevel;
        vars.prevInfamyPoints = vars.infamyPoints;
        vars.prevLastBossLevelDefeated = vars.lastBossLevelDefeated;
        vars.prevBountyWorldName = vars.bountyWorldName;
        vars.prevIsBaseGameWorld = vars.isBaseGameWorld;
        vars.prevIsDlcWorld = vars.isDlcWorld;

        vars.infamyLevel = vars.readInfamyLevel;
        vars.infamyPoints = vars.readInfamyPoints;
        vars.lastBossLevelDefeated = vars.readLastBossLevelDefeated;
        vars.currentBountyManager = vars.readCurrentBountyManager;
        vars.bountyWorldName = vars.readBountyWorldName;
        vars.isBaseGameWorld = vars.readIsBaseGameWorld;
        vars.isDlcWorld = vars.readIsDlcWorld;

        vars.hadValidBountyStateRead = true;
    });

    vars.ReadUObjectName = (Func<IntPtr, string>)((obj) =>
    {
        try
        {
            int objNameIndex = memory.ReadValue<int>(new IntPtr(obj.ToInt64() + 0x18));
            int objNameNumber = memory.ReadValue<int>(new IntPtr(obj.ToInt64() + 0x1C));
            string objName = "";

            if (!vars.Names.TryGetValue(objNameIndex, out objName))
            {
                return null;
            }

            if (objNameNumber > 0)
            {
                objName = objName + "_" + (objNameNumber - 1);
            }

            return objName;
        }
        catch
        {
            return null;
        }
    });

    vars.ReadUObjectClassName = (Func<IntPtr, string>)((obj) =>
    {
        try
        {
            IntPtr classPtr = memory.ReadValue<IntPtr>(new IntPtr(obj.ToInt64() + 0x10));

            if (classPtr == IntPtr.Zero)
            {
                return null;
            }

            int classNameIndex = memory.ReadValue<int>(new IntPtr(classPtr.ToInt64() + 0x18));
            int classNameNumber = memory.ReadValue<int>(new IntPtr(classPtr.ToInt64() + 0x1C));
            string className = "";

            if (!vars.Names.TryGetValue(classNameIndex, out className))
            {
                return null;
            }

            if (classNameNumber > 0)
            {
                className = className + "_" + (classNameNumber - 1);
            }

            return className;
        }
        catch
        {
            return null;
        }
    });

    vars.ReadUObjectFullName = (Func<IntPtr, string>)((obj) =>
    {
        try
        {
            string objName = vars.ReadUObjectName(obj);
            string className = vars.ReadUObjectClassName(obj);

            if (objName == null || className == null)
            {
                return null;
            }

            var outers = new List<string>();
            IntPtr outer = memory.ReadValue<IntPtr>(new IntPtr(obj.ToInt64() + 0x20));
            int depth = 0;

            while (outer != IntPtr.Zero && depth < 8)
            {
                string outerName = vars.ReadUObjectName(outer);

                if (outerName == null)
                {
                    break;
                }

                outers.Add(outerName);
                outer = memory.ReadValue<IntPtr>(new IntPtr(outer.ToInt64() + 0x20));
                depth++;
            }

            string outerPath = "";

            for (int i = outers.Count - 1; i >= 0; i--)
            {
                outerPath = outerPath + outers[i] + ".";
            }

            return className + " " + outerPath + objName;
        }
        catch
        {
            return null;
        }
    });

    vars.ReadUObjectOuterChain = (Func<IntPtr, string>)((obj) =>
    {
        try
        {
            var parts = new List<string>();
            IntPtr outer = memory.ReadValue<IntPtr>(new IntPtr(obj.ToInt64() + 0x20));
            int depth = 0;

            while (outer != IntPtr.Zero && depth < 8)
            {
                string outerName = vars.ReadUObjectName(outer);
                string outerClass = vars.ReadUObjectClassName(outer);

                if (outerName == null)
                {
                    outerName = "?";
                }

                if (outerClass == null)
                {
                    outerClass = "?";
                }

                parts.Add("0x" + outer.ToInt64().ToString("X") + ":" + outerName + "(" + outerClass + ")");
                outer = memory.ReadValue<IntPtr>(new IntPtr(outer.ToInt64() + 0x20));
                depth++;
            }

            if (parts.Count == 0)
            {
                return "";
            }

            return String.Join(" <- ", parts.ToArray());
        }
        catch
        {
            return "";
        }
    });

    vars.ReadGameplayWorldState = (Func<Process, bool>)((proc) =>
    {
        vars.readGameplayWorldPtr = IntPtr.Zero;
        vars.readGameplayWorldName = "";
        vars.readIsGameplayWorld = false;
        vars.readIsNonGameplayWorld = true;

        try
        {
            long gworldOffset = version == "Steam" ? 0x04AE2960 : 0x04AEAB90;
            IntPtr gworld = memory.ReadValue<IntPtr>(new IntPtr(modules.First().BaseAddress.ToInt64() + gworldOffset));

            if (gworld == IntPtr.Zero)
            {
                return false;
            }

            string worldName = vars.ReadUObjectName(gworld);

            if (worldName == null)
            {
                return false;
            }

            bool gameplayWorld =
                worldName == "WorldMap_P" ||
                worldName == "DLC_WorldMap_P";

            vars.readGameplayWorldPtr = gworld;
            vars.readGameplayWorldName = worldName;
            vars.readIsGameplayWorld = gameplayWorld;
            vars.readIsNonGameplayWorld = !gameplayWorld;
            return true;
        }
        catch
        {
            return false;
        }
    });

    vars.BuildPointerIdentityLogs = (Func<Process, List<string>>)((proc) =>
    {
        var logs = new List<string>();
        IntPtr baseAddr = modules.First().BaseAddress;

        Func<IntPtr, string> Hex = (ptr) => "0x" + ptr.ToInt64().ToString("X");

        Func<IntPtr, string, string> Verdict = (ptr, expectedClassPart) =>
        {
            if (ptr == IntPtr.Zero)
            {
                return "invalid";
            }

            string name = vars.ReadUObjectName(ptr);
            string className = vars.ReadUObjectClassName(ptr);
            string fullName = vars.ReadUObjectFullName(ptr);

            if (name == null || className == null || fullName == null)
            {
                return "value_match";
            }

            if (className.Contains(expectedClassPart) || fullName.Contains(expectedClassPart))
            {
                return "real";
            }

            return "probably_real";
        };

        Func<string, IntPtr, string, string> UObjectPrefix = (chainName, ptr, expectedClassPart) =>
        {
            int objNameIndex = -1;
            int objNameNumber = -1;
            IntPtr classPtr = IntPtr.Zero;
            int classNameIndex = -1;
            int classNameNumber = -1;

            try
            {
                objNameIndex = memory.ReadValue<int>(new IntPtr(ptr.ToInt64() + 0x18));
                objNameNumber = memory.ReadValue<int>(new IntPtr(ptr.ToInt64() + 0x1C));
                classPtr = memory.ReadValue<IntPtr>(new IntPtr(ptr.ToInt64() + 0x10));

                if (classPtr != IntPtr.Zero)
                {
                    classNameIndex = memory.ReadValue<int>(new IntPtr(classPtr.ToInt64() + 0x18));
                    classNameNumber = memory.ReadValue<int>(new IntPtr(classPtr.ToInt64() + 0x1C));
                }
            }
            catch
            {
            }

            string name = vars.ReadUObjectName(ptr);
            string className = vars.ReadUObjectClassName(ptr);
            string fullName = vars.ReadUObjectFullName(ptr);
            bool validUObject = name != null && className != null && fullName != null;

            return
                "chain=" + chainName +
                " ptr=" + Hex(ptr) +
                " uobjectValid=" + validUObject +
                " nameRaw=" + objNameIndex + ":" + objNameNumber +
                " classPtr=" + Hex(classPtr) +
                " classNameRaw=" + classNameIndex + ":" + classNameNumber +
                " name=" + name +
                " class=" + className +
                " fullName=" + fullName +
                " verdict=" + Verdict(ptr, expectedClassPart);
        };

        try
        {
            IntPtr p0 = memory.ReadValue<IntPtr>(new IntPtr(baseAddr.ToInt64() + 0x04AE7120));
            IntPtr p1 = memory.ReadValue<IntPtr>(new IntPtr(p0.ToInt64() + 0x0));
            IntPtr p2 = memory.ReadValue<IntPtr>(new IntPtr(p1.ToInt64() + 0x10));
            IntPtr p3 = memory.ReadValue<IntPtr>(new IntPtr(p2.ToInt64() + 0xB8));
            IntPtr playerState = memory.ReadValue<IntPtr>(new IntPtr(p3.ToInt64() + 0x228));
            int currentLevel = memory.ReadValue<int>(new IntPtr(playerState.ToInt64() + 0x39C));
            int theoreticalLevel = memory.ReadValue<int>(new IntPtr(playerState.ToInt64() + 0x3C0));
            int growthStage = memory.ReadValue<int>(new IntPtr(playerState.ToInt64() + 0x3C4));

            logs.Add(
                UObjectPrefix("PlayerSharkState", playerState, "PlayerSharkState") +
                " currentLevel_39C=" + currentLevel +
                " theoreticalLevel_3C0=" + theoreticalLevel +
                " growthStage_3C4=" + growthStage
            );
        }
        catch
        {
            logs.Add("chain=PlayerSharkState ptr=0x0 uobjectValid=False verdict=invalid reason=ReadFailed");
        }

        try
        {
            IntPtr p0 = memory.ReadValue<IntPtr>(new IntPtr(baseAddr.ToInt64() + 0x0486F1D0));
            IntPtr p1 = memory.ReadValue<IntPtr>(new IntPtr(p0.ToInt64() + 0x128));
            IntPtr p2 = memory.ReadValue<IntPtr>(new IntPtr(p1.ToInt64() + 0x660));
            IntPtr p3 = memory.ReadValue<IntPtr>(new IntPtr(p2.ToInt64() + 0x130));
            IntPtr objectiveManager = memory.ReadValue<IntPtr>(new IntPtr(p3.ToInt64() + 0x20));
            int completedNum = memory.ReadValue<int>(new IntPtr(objectiveManager.ToInt64() + 0x380));
            int activeStoryIndex = memory.ReadValue<int>(new IntPtr(objectiveManager.ToInt64() + 0x3A8));
            int storyConditions = memory.ReadValue<int>(new IntPtr(objectiveManager.ToInt64() + 0x3AC));

            logs.Add(
                UObjectPrefix("ObjectiveManager", objectiveManager, "PlayerObjectiveManager") +
                " completedNum_380=" + completedNum +
                " activeStoryIndex_3A8=" + activeStoryIndex +
                " storyEventConditionsComplete_3AC=" + storyConditions
            );
        }
        catch
        {
            logs.Add("chain=ObjectiveManager ptr=0x0 uobjectValid=False verdict=invalid reason=ReadFailed");
        }

        try
        {
            IntPtr p0 = memory.ReadValue<IntPtr>(new IntPtr(baseAddr.ToInt64() + 0x0486F1D0));
            IntPtr p1 = memory.ReadValue<IntPtr>(new IntPtr(p0.ToInt64() + 0x498));
            IntPtr p2 = memory.ReadValue<IntPtr>(new IntPtr(p1.ToInt64() + 0x28));
            IntPtr p3 = memory.ReadValue<IntPtr>(new IntPtr(p2.ToInt64() + 0x8));
            IntPtr p4 = memory.ReadValue<IntPtr>(new IntPtr(p3.ToInt64() + 0xF0));
            IntPtr bountyManager = memory.ReadValue<IntPtr>(new IntPtr(p4.ToInt64() + 0x5D8));
            int infamyLevel = memory.ReadValue<int>(new IntPtr(bountyManager.ToInt64() + 0x394));
            int lastBoss = memory.ReadValue<int>(new IntPtr(bountyManager.ToInt64() + 0x3A4));

            logs.Add(
                UObjectPrefix("BountyManager", bountyManager, "BountyManager") +
                " outerChain=" + vars.ReadUObjectOuterChain(bountyManager) +
                " playerInfamyLevel_394=" + infamyLevel +
                " lastBossLevelDefeated_3A4=" + lastBoss
            );
        }
        catch
        {
            logs.Add("chain=BountyManager ptr=0x0 uobjectValid=False verdict=invalid reason=ReadFailed");
        }

        try
        {
            long gworldOffset = version == "Steam" ? 0x04AE2960 : 0x04AEAB90;
            IntPtr gworld = memory.ReadValue<IntPtr>(new IntPtr(baseAddr.ToInt64() + gworldOffset));
            byte streamingPending = memory.ReadValue<byte>(new IntPtr(gworld.ToInt64() + 0x4E0));
            byte byte11B = memory.ReadValue<byte>(new IntPtr(gworld.ToInt64() + 0x11B));
            byte byte11D = memory.ReadValue<byte>(new IntPtr(gworld.ToInt64() + 0x11D));

            logs.Add(
                UObjectPrefix("GWorld", gworld, "World") +
                " byte_4E0=" + streamingPending +
                " byte_11B=" + byte11B +
                " byte_11D=" + byte11D
            );
        }
        catch
        {
            logs.Add("chain=GWorld ptr=0x0 uobjectValid=False verdict=invalid reason=ReadFailed");
        }

        return logs;
    });

    vars.ReadCompletedObjectiveGuids = (Func<Process, HashSet<string>>)((proc) =>
    {
        IntPtr completedData = IntPtr.Zero;
        int completedNum = 0;
        int completedMax = 0;

        if (!vars.completedObjectivesDataPtr.Deref<IntPtr>(proc, out completedData))
        {
            vars.objectiveReadFailReason = "DataPtrDerefFailed";
            return null;
        }

        if (!vars.completedObjectivesNumPtr.Deref<int>(proc, out completedNum))
        {
            vars.objectiveReadFailReason = "NumPtrDerefFailed";
            return null;
        }

        if (!vars.completedObjectivesMaxPtr.Deref<int>(proc, out completedMax))
        {
            vars.objectiveReadFailReason = "MaxPtrDerefFailed";
            return null;
        }

        if (completedData == IntPtr.Zero && completedNum > 0)
        {
            vars.objectiveReadFailReason = "CompletedDataZeroWithNum:" + completedNum;
            return null;
        }

        if (completedNum < 0 || completedNum > 200)
        {
            vars.objectiveReadFailReason = "CompletedNumOutOfRange:" + completedNum;
            return null;
        }

        if (completedMax < completedNum || completedMax > 256)
        {
            vars.objectiveReadFailReason = "CompletedMaxOutOfRange:" + completedMax + " Num=" + completedNum;
            return null;
        }

        var readGuids = new HashSet<string>();
        var readNameKeys = new HashSet<string>();
        var objectiveDebugRows = new List<string>();
        vars.previousCompletedObjectivesNum = vars.lastCompletedObjectivesNum;
        vars.lastCompletedObjectiveName = "";
        vars.lastCompletedObjectiveGuid = "";
        vars.readTutorialObjectiveFound = false;
        vars.readTutorialComplete = false;
        vars.readTutorialStateF0 = -1;
        vars.readTutorialType79 = -1;
        vars.readTutorialFlagF1 = -1;

        for (int i = 0; i < completedNum; i++)
        {
            try
            {
                IntPtr obj = memory.ReadValue<IntPtr>(new IntPtr(completedData.ToInt64() + (i * 0x8)));

                if (obj == IntPtr.Zero)
                {
                    objectiveDebugRows.Add(
                        "index=" + i +
                        " obj=0x0" +
                        " name=" +
                        " fullName=" +
                        " guid=" +
                        " type79=-1" +
                        " stateF0=-1"
                    );
                    continue;
                }

                byte type79 = memory.ReadValue<byte>(new IntPtr(obj.ToInt64() + 0x79));
                byte stateF0 = memory.ReadValue<byte>(new IntPtr(obj.ToInt64() + 0xF0));
                byte flagF1 = memory.ReadValue<byte>(new IntPtr(obj.ToInt64() + 0xF1));

                if (type79 == 0x0F && flagF1 == 1)
                {
                    vars.readTutorialObjectiveFound = true;
                    vars.readTutorialType79 = (int)type79;
                    vars.readTutorialFlagF1 = (int)flagF1;
                    vars.readTutorialStateF0 = (int)stateF0;

                    if (stateF0 == 3)
                    {
                        vars.readTutorialComplete = true;
                    }
                }

                uint guidA = memory.ReadValue<uint>(new IntPtr(obj.ToInt64() + 0x40));
                uint guidB = memory.ReadValue<uint>(new IntPtr(obj.ToInt64() + 0x44));
                uint guidC = memory.ReadValue<uint>(new IntPtr(obj.ToInt64() + 0x48));
                uint guidD = memory.ReadValue<uint>(new IntPtr(obj.ToInt64() + 0x4C));

                string objName = vars.ReadUObjectName(obj);
                string className = vars.ReadUObjectClassName(obj);
                string fullName = vars.ReadUObjectFullName(obj);
                string guidKey = "";

                if (!(guidA == 0u && guidB == 0u && guidC == 0u && guidD == 0u))
                {
                    guidKey = vars.MakeGuidKey(guidA, guidB, guidC, guidD);
                }

                if (objName == null)
                {
                    objName = "";
                }

                if (className == null)
                {
                    className = "";
                }

                if (fullName == null)
                {
                    fullName = "";
                }

                objectiveDebugRows.Add(
                    "index=" + i +
                    " obj=0x" + obj.ToInt64().ToString("X") +
                    " name=" + objName +
                    " fullName=" + fullName +
                    " guid=" + guidKey +
                    " type79=0x" + ((int)type79).ToString("X2") +
                    " stateF0=" + ((int)stateF0)
                );

                vars.lastCompletedObjectiveName = objName;
                vars.lastCompletedObjectiveGuid = guidKey;

                if (objName != "" && className != "")
                {
                    readNameKeys.Add(vars.MakeNameKey(objName, className));

                    if (false)
                    {
                        
                    }
                }

                if (guidA == 0u && guidB == 0u && guidC == 0u && guidD == 0u)
                {
                    continue;
                }

                readGuids.Add(guidKey);
            }
            catch
            {
                objectiveDebugRows.Add(
                    "index=" + i +
                    " obj=0x0" +
                    " name=<unreadable>" +
                    " fullName=<unreadable>" +
                    " guid=" +
                    " type79=-1" +
                    " stateF0=-1"
                );
                continue;
            }
        }

        vars.lastCompletedObjectivesData = completedData;
        vars.lastCompletedObjectivesNum = completedNum;
        vars.lastCompletedObjectivesMax = completedMax;
        vars.lastReadCompletedObjectiveNameKeys = readNameKeys;
        vars.currentCompletedObjectiveDebugRows = objectiveDebugRows;
        if (!vars.tutorialComplete && vars.readTutorialComplete)
        {
            vars.pendingLevel1SplitOnTutorialComplete = true;
        }

        vars.tutorialObjectiveFound = vars.readTutorialObjectiveFound;
        vars.tutorialComplete = vars.readTutorialComplete;
        vars.tutorialStateF0 = vars.readTutorialStateF0;
        vars.tutorialType79 = vars.readTutorialType79;
        vars.tutorialFlagF1 = vars.readTutorialFlagF1;
        vars.objectiveReadFailReason = "";

        return readGuids;
    });
}

update
{
    vars.suppressSplitThisUpdate = false;
    vars.canSplitObjectivesThisFrame = false;
    vars.canSplitStoryStateThisFrame = false;
    vars.canSplitPlayerStateThisFrame = false;
    vars.canSplitBountyStateThisFrame = false;

    if (!vars.NamesInitialized && vars.GNames != IntPtr.Zero)
    {
        vars.Names = vars.DumpNames();
        vars.NamesInitialized = true;
        
    }
    bool loading = version == "Epic" && current.moviePlayerLoading == 1;

    if (vars.wasLoading && !loading)
    {
        vars.playerStateBaselineDelayFrames = 5;
    }

    vars.wasLoading = loading;

    if (loading)
    {
        if ((vars.hasStoryStateBaseline || vars.hadValidStoryStateRead) &&
            vars.activeStoryIndex > 0)
        {
            vars.hadStoryIndexBeforeLoad = true;
            vars.storyIndexBeforeLoad = vars.activeStoryIndex;
            vars.storyConditionsBeforeLoad = vars.storyEventConditionsComplete;
        }

        vars.suppressSplitThisUpdate = true;
        vars.hadValidObjectiveRead = false;
        vars.hadValidStoryStateRead = false;
        vars.hasStoryStateBaseline = false;
        vars.canSplitStoryStateThisFrame = false;
        vars.completedObjectivesNumIncreaseRecentFrames = 0;
        vars.hadValidPlayerStateRead = false;
        vars.hasPlayerStateBaseline = false;
        vars.playerStateLastValid = false;
        vars.playerStateBaselineDelayFrames = 5;
        vars.hadValidBountyStateRead = false;
        vars.hasBountyStateBaseline = false;
        vars.canLevelSplit = false;
        return true;
    }

    bool gameplayWorldRead = vars.ReadGameplayWorldState(game);
    bool readGameplayWorld = gameplayWorldRead && vars.readIsGameplayWorld;

    vars.gameplayWorldPtr = vars.readGameplayWorldPtr;
    vars.gameplayWorldName = gameplayWorldRead ? vars.readGameplayWorldName : "";
    vars.isGameplayWorld = readGameplayWorld;
    vars.isNonGameplayWorld = !readGameplayWorld;

    vars.wasGameplayWorld = vars.isGameplayWorld;

    bool debugWorldState =
        false ||
        false ||
        false ||
        false ||
        false;

    string gameplayWorldStateLog =
        "worldPtr=0x" + vars.gameplayWorldPtr.ToInt64().ToString("X") +
        " worldName=" + vars.gameplayWorldName +
        " isGameplayWorld=" + vars.isGameplayWorld +
        " isNonGameplayWorld=" + vars.isNonGameplayWorld;

    if (debugWorldState && gameplayWorldStateLog != vars.lastLoggedGameplayWorldState)
    {
        vars.lastLoggedGameplayWorldState = gameplayWorldStateLog;
        
    }

    if (!vars.isGameplayWorld)
    {
        vars.suppressSplitThisUpdate = true;
        vars.hadValidObjectiveRead = false;
        vars.hasObjectiveBaseline = false;
        vars.hadValidStoryStateRead = false;
        vars.hasStoryStateBaseline = false;
        vars.canSplitStoryStateThisFrame = false;
        vars.hadValidPlayerStateRead = false;
        vars.hasPlayerStateBaseline = false;
        vars.playerStateLastValid = false;
        vars.canSplitPlayerStateThisFrame = false;
        vars.hadValidBountyStateRead = false;
        vars.hasBountyStateBaseline = false;
        vars.canSplitBountyStateThisFrame = false;
        vars.canLevelSplit = false;
        return true;
    }

    var readGuids = vars.ReadCompletedObjectiveGuids(game);

    if (readGuids == null)
    {
        if (false && vars.lastObjectiveReadFailReason != vars.objectiveReadFailReason)
        {
            vars.lastObjectiveReadFailReason = vars.objectiveReadFailReason;
            
        }

        vars.hadValidObjectiveRead = false;
        return true;
    }

    if (false && vars.lastObjectiveReadFailReason != "")
    {
        vars.lastObjectiveReadFailReason = "";
        
    }

    bool playerStateRead = vars.ReadPlayerSharkState(game);
    bool bountyStateRead = vars.ReadBountyState(game);
    int readActiveStoryIndex = 0;
    int readStoryEventConditionsComplete = 0;
    bool storyStateRead =
        vars.activeStoryIndexPtr.Deref<int>(game, out readActiveStoryIndex) &&
        vars.storyEventConditionsCompletePtr.Deref<int>(game, out readStoryEventConditionsComplete);

    if (storyStateRead)
    {
        vars.readActiveStoryIndex = readActiveStoryIndex;
        vars.readStoryEventConditionsComplete = readStoryEventConditionsComplete;
    }
    else
    {
        vars.hadValidStoryStateRead = false;
        vars.hasStoryStateBaseline = false;
    }

    if (false)
    {
        vars.debugPointerIdentityFrameCounter++;

        if (vars.debugPointerIdentityFrameCounter >= 120)
        {
            vars.debugPointerIdentityFrameCounter = 0;
            var pointerLogs = vars.BuildPointerIdentityLogs(game);
            string combinedPointerLog = "";

            foreach (string line in pointerLogs)
            {
                combinedPointerLog = combinedPointerLog + line + "\n";
            }

            if (combinedPointerLog != vars.lastLoggedPointerIdentity)
            {
                vars.lastLoggedPointerIdentity = combinedPointerLog;

                foreach (string line in pointerLogs)
                {
                    
                }
            }
        }
    }

    if (!playerStateRead)
    {
        if (settings["splits_player_state"] && vars.lastPlayerStateReadFailReason != vars.playerStateReadFailReason)
        {
            vars.lastPlayerStateReadFailReason = vars.playerStateReadFailReason;
        }

        vars.hadValidPlayerStateRead = false;
        vars.hasPlayerStateBaseline = false;
        vars.playerStateLastValid = false;

        if (false)
        {
            string playerStateLog =
                "ptr=0x" + vars.readPlayerSharkStatePtr.ToInt64().ToString("X") +
                " valid=false" +
                " level=" + vars.readPlayerCurrentPlayerLevel +
                " theoreticalLevel=" + vars.readPlayerTheoreticalPlayerLevel +
                " exp=" + vars.readPlayerCurrentExpAmount +
                " growth=" + vars.readPlayerCurrentGrowthStage +
                " reason=" + vars.playerStateReadFailReason;

            if (playerStateLog != vars.lastLoggedPlayerState)
            {
                vars.lastLoggedPlayerState = playerStateLog;
                
            }
        }
    }
    else
    {
        if (vars.lastPlayerStateReadFailReason != "")
        {
            vars.lastPlayerStateReadFailReason = "";
        }

        string playerStateLog =
            "ptr=0x" + vars.readPlayerSharkStatePtr.ToInt64().ToString("X") +
            " valid=true" +
            " level=" + vars.readPlayerCurrentPlayerLevel +
            " theoreticalLevel=" + vars.readPlayerTheoreticalPlayerLevel +
            " exp=" + vars.readPlayerCurrentExpAmount +
            " growth=" + vars.readPlayerCurrentGrowthStage;

        if (false && playerStateLog != vars.lastLoggedPlayerState)
        {
            vars.lastLoggedPlayerState = playerStateLog;
            
        }
    }

    if (!bountyStateRead)
    {
        if (false && vars.lastBountyStateReadFailReason != vars.bountyStateReadFailReason)
        {
            vars.lastBountyStateReadFailReason = vars.bountyStateReadFailReason;
        }

        vars.hadValidBountyStateRead = false;
        vars.hasBountyStateBaseline = false;
    }
    else
    {
        if (vars.lastBountyStateReadFailReason != "")
        {
            vars.lastBountyStateReadFailReason = "";
        }

        vars.debugBountyFrameCounter++;

        if (false && vars.debugBountyFrameCounter >= 120)
        {
            vars.debugBountyFrameCounter = 0;
            string bountyStateLog =
                "world=" + vars.readBountyWorldName +
                " infamy=" + vars.readInfamyLevel +
                " points=" + vars.readInfamyPoints +
                " lastBoss=" + vars.readLastBossLevelDefeated;

            if (bountyStateLog != vars.lastLoggedBountyState)
            {
                vars.lastLoggedBountyState = bountyStateLog;
                
            }
        }
    }

    vars.canLevelSplit =
        vars.isDlcWorld ||
        vars.readIsDlcWorld ||
        ((vars.isBaseGameWorld || vars.readIsBaseGameWorld) &&
         vars.tutorialObjectiveFound &&
         vars.tutorialComplete);

    if (false)
    {
        vars.debugTutorialFrameCounter++;

            if (vars.debugTutorialFrameCounter >= 120)
            {
                vars.debugTutorialFrameCounter = 0;
                int tutorialType79 = vars.tutorialType79;
                string tutorialType79Text = tutorialType79 < 0 ? "-1" : "0x" + tutorialType79.ToString("X2");

                string tutorialStateLog =
                    "found=" + vars.tutorialObjectiveFound +
                    " complete=" + vars.tutorialComplete +
                    " stateF0=" + vars.tutorialStateF0 +
                    " type79=" + tutorialType79Text +
                    " flagF1=" + vars.tutorialFlagF1 +
                    " canLevelSplit=" + vars.canLevelSplit;

            if (tutorialStateLog != vars.lastLoggedTutorialState)
            {
                vars.lastLoggedTutorialState = tutorialStateLog;
                
            }
        }
    }

    if (false)
    {
        vars.debugObjectiveFrameCounter++;

        string guidDump = "";
        foreach (string guid in readGuids)
        {
            guidDump = guidDump + guid + "|";
        }

        bool shouldLogObjectives =
            vars.lastLoggedCompletedNum != vars.lastCompletedObjectivesNum ||
            vars.lastLoggedGuidDump != guidDump ||
            vars.debugObjectiveFrameCounter >= 120;

        if (shouldLogObjectives)
        {
            vars.debugObjectiveFrameCounter = 0;
            vars.lastLoggedCompletedNum = vars.lastCompletedObjectivesNum;
            vars.lastLoggedGuidDump = guidDump;

            

            foreach (string guid in readGuids)
            {
                
            }

            foreach (var pair in vars.targetGuids)
            {
                uint[] g = pair.Value;
                string targetGuid = vars.MakeGuidKey(g[0], g[1], g[2], g[3]);
                
            }
        }
    }

    if (timer.CurrentPhase == TimerPhase.NotRunning)
    {
        vars.splittedObjectives.Clear();
        vars.hadValidObjectiveRead = false;
        vars.hasObjectiveBaseline = false;
        vars.prevCompletedObjectiveGuids.Clear();
        vars.completedObjectiveGuids.Clear();
        vars.prevCompletedObjectiveNameKeys.Clear();
        vars.completedObjectiveNameKeys.Clear();
        vars.pendingObjectiveSplits.Clear();
        vars.splittedStoryState.Clear();
        vars.pendingStorySplits.Clear();
        vars.hadValidStoryStateRead = false;
        vars.hasStoryStateBaseline = false;
        vars.canSplitStoryStateThisFrame = false;
        vars.prevActiveStoryIndex = 0;
        vars.activeStoryIndex = 0;
        vars.readActiveStoryIndex = 0;
        vars.prevStoryEventConditionsComplete = 0;
        vars.storyEventConditionsComplete = 0;
        vars.readStoryEventConditionsComplete = 0;
        vars.hadStoryIndexBeforeLoad = false;
        vars.storyIndexBeforeLoad = 0;
        vars.storyConditionsBeforeLoad = 0;
        vars.completedObjectivesNumIncreaseRecentFrames = 0;
        vars.splittedPlayerState.Clear();
        vars.pendingPlayerLevelSplits.Clear();
        vars.pendingPlayerXPSplits.Clear();
        vars.hadValidPlayerStateRead = false;
        vars.hasPlayerStateBaseline = false;
        vars.playerStateLastValid = false;
        vars.canLevelSplit = false;
        vars.playerStateBaselineDelayFrames = 1;
        vars.tutorialObjectiveFound = false;
        vars.tutorialComplete = false;
        vars.pendingLevel1SplitOnTutorialComplete = false;
        vars.tutorialStateF0 = -1;
        vars.tutorialType79 = -1;
        vars.tutorialFlagF1 = -1;
        vars.splittedBountyState.Clear();
        vars.pendingInfamySplits.Clear();
        vars.pendingDlcInfamySplits.Clear();
        vars.hadValidBountyStateRead = false;
        vars.hasBountyStateBaseline = false;
        vars.isBaseGameWorld = false;
        vars.isDlcWorld = false;
        vars.bountyWorldName = "";
        vars.isGameplayWorld = false;
        vars.isNonGameplayWorld = true;
        vars.readIsGameplayWorld = false;
        vars.readIsNonGameplayWorld = true;
        vars.gameplayWorldName = "";
        vars.readGameplayWorldName = "";
        vars.gameplayWorldPtr = IntPtr.Zero;
        vars.readGameplayWorldPtr = IntPtr.Zero;
        vars.wasGameplayWorld = false;
        vars.previousCompletedObjectivesNum = 0;
        vars.lastCompletedObjectiveName = "";
        vars.lastCompletedObjectiveGuid = "";
        vars.currentCompletedObjectiveDebugRows.Clear();
        vars.lastLoggedStoryState = "";
        vars.suppressSplitThisUpdate = true;
        return true;
    }

    if (!vars.hasObjectiveBaseline)
    {
        vars.prevCompletedObjectiveGuids = readGuids;
        vars.completedObjectiveGuids = readGuids;
        vars.prevCompletedObjectiveNameKeys = vars.lastReadCompletedObjectiveNameKeys;
        vars.completedObjectiveNameKeys = vars.lastReadCompletedObjectiveNameKeys;
        vars.hasObjectiveBaseline = true;
        vars.hadValidObjectiveRead = true;
        if (bountyStateRead)
        {
            vars.AbsorbBountyStateBaseline();
        }
        if (storyStateRead)
        {
            vars.prevActiveStoryIndex = vars.readActiveStoryIndex;
            vars.activeStoryIndex = vars.readActiveStoryIndex;
            vars.prevStoryEventConditionsComplete = vars.readStoryEventConditionsComplete;
            vars.storyEventConditionsComplete = vars.readStoryEventConditionsComplete;
            vars.hasStoryStateBaseline = true;
            vars.hadValidStoryStateRead = true;
            vars.canSplitStoryStateThisFrame = false;
        }
        vars.suppressSplitThisUpdate = true;
        return true;
    }

    if (playerStateRead)
    {
        if (vars.playerStateBaselineDelayFrames > 0)
        {
            vars.playerStateBaselineDelayFrames--;
            vars.hadValidPlayerStateRead = false;
            vars.hasPlayerStateBaseline = false;
            vars.canSplitPlayerStateThisFrame = false;
        }
        else if (!vars.hasPlayerStateBaseline || !vars.hadValidPlayerStateRead)
        {
            vars.AbsorbPlayerSharkStateBaseline();
        }
        else
        {
            vars.UpdatePlayerSharkState();
            vars.canSplitPlayerStateThisFrame = true;

            if (vars.playerStateLastValid && vars.canLevelSplit)
            {
                foreach (var pair in vars.targetLevelSplits)
                {
                    string settingId = pair.Key;

                    if (!settings[settingId])
                    {
                        continue;
                    }

                    if (vars.splittedPlayerState.Contains(settingId) ||
                        vars.pendingPlayerLevelSplits.Contains(settingId))
                    {
                        continue;
                    }

                    int targetLevel = pair.Value;
                    int prevEffectiveLevel = vars.prevPlayerCurrentPlayerLevel;
                    int effectiveLevel = vars.playerCurrentPlayerLevel;

                    if (vars.prevPlayerTheoreticalPlayerLevel > prevEffectiveLevel)
                    {
                        prevEffectiveLevel = vars.prevPlayerTheoreticalPlayerLevel;
                    }

                    if (vars.playerTheoreticalPlayerLevel > effectiveLevel)
                    {
                        effectiveLevel = vars.playerTheoreticalPlayerLevel;
                    }

                    if (prevEffectiveLevel < targetLevel &&
                        effectiveLevel >= targetLevel)
                    {
                        vars.pendingPlayerLevelSplits.Add(settingId);
                        if (false)
                        {
                            
                        }
                    }
                }
            }

            if (vars.playerStateLastValid)
            {
                foreach (var pair in vars.targetXPSplits)
                {
                    string settingId = pair.Key;

                    if (!settings[settingId])
                    {
                        continue;
                    }

                    if (vars.splittedPlayerState.Contains(settingId) ||
                        vars.pendingPlayerXPSplits.Contains(settingId))
                    {
                        continue;
                    }

                    int targetXp = pair.Value;

                    if (vars.prevPlayerCurrentExpAmount < targetXp &&
                        vars.playerCurrentExpAmount >= targetXp)
                    {
                        vars.pendingPlayerXPSplits.Add(settingId);
                    }
                }
            }
        }
    }

    if (bountyStateRead)
    {
        if (!vars.hasBountyStateBaseline || !vars.hadValidBountyStateRead)
        {
            vars.AbsorbBountyStateBaseline();
        }
        else
        {
            vars.UpdateBountyState();
            vars.canSplitBountyStateThisFrame = true;

            if (vars.isBaseGameWorld)
            {
                foreach (var pair in vars.targetInfamySplits)
                {
                    string settingId = pair.Key;

                    if (!settings[settingId])
                    {
                        continue;
                    }

                    if (vars.splittedBountyState.Contains(settingId) ||
                        vars.pendingInfamySplits.Contains(settingId))
                    {
                        continue;
                    }

                    int targetInfamy = pair.Value;

                    if (vars.prevInfamyLevel < targetInfamy &&
                        vars.infamyLevel >= targetInfamy)
                    {
                        vars.pendingInfamySplits.Add(settingId);
                    }
                }
            }

            if (vars.isDlcWorld)
            {
                foreach (var pair in vars.targetDlcInfamySplits)
                {
                    string settingId = pair.Key;

                    if (!settings[settingId])
                    {
                        continue;
                    }

                    if (vars.splittedBountyState.Contains(settingId) ||
                        vars.pendingDlcInfamySplits.Contains(settingId))
                    {
                        continue;
                    }

                    int targetInfamy = pair.Value;

                    if (vars.prevInfamyLevel < targetInfamy &&
                        vars.infamyLevel >= targetInfamy)
                    {
                        vars.pendingDlcInfamySplits.Add(settingId);
                    }
                }
            }
        }
    }

    if (storyStateRead)
    {
        if (!vars.hasStoryStateBaseline || !vars.hadValidStoryStateRead)
        {
            if (vars.hadStoryIndexBeforeLoad &&
                vars.storyIndexBeforeLoad > 0 &&
                vars.readActiveStoryIndex > vars.storyIndexBeforeLoad &&
                vars.readActiveStoryIndex == vars.storyIndexBeforeLoad + 1 &&
                timer.CurrentPhase != TimerPhase.NotRunning)
            {
                foreach (var pair in vars.targetStorySplits)
                {
                    string settingId = pair.Key;

                    if (!settings[settingId])
                    {
                        continue;
                    }

                    if (vars.splittedStoryState.Contains(settingId) ||
                        vars.pendingStorySplits.Contains(settingId))
                    {
                        continue;
                    }

                    int targetActiveStoryIndex = pair.Value;

                    if (vars.readActiveStoryIndex == targetActiveStoryIndex)
                    {
                        vars.pendingStorySplits.Add(settingId);
                        if (false)
                        {
                            
                        }
                    }
                }
            }

            vars.hadStoryIndexBeforeLoad = false;
            vars.prevActiveStoryIndex = vars.readActiveStoryIndex;
            vars.activeStoryIndex = vars.readActiveStoryIndex;
            vars.prevStoryEventConditionsComplete = vars.readStoryEventConditionsComplete;
            vars.storyEventConditionsComplete = vars.readStoryEventConditionsComplete;
            vars.hasStoryStateBaseline = true;
            vars.hadValidStoryStateRead = true;
            vars.canSplitStoryStateThisFrame = false;
        }
        else
        {
            vars.prevActiveStoryIndex = vars.activeStoryIndex;
            vars.activeStoryIndex = vars.readActiveStoryIndex;
            vars.prevStoryEventConditionsComplete = vars.storyEventConditionsComplete;
            vars.storyEventConditionsComplete = vars.readStoryEventConditionsComplete;
            vars.hadValidStoryStateRead = true;
            vars.canSplitStoryStateThisFrame = true;
        }
    }

    vars.prevCompletedObjectiveGuids = vars.completedObjectiveGuids;
    vars.completedObjectiveGuids = readGuids;
    vars.prevCompletedObjectiveNameKeys = vars.completedObjectiveNameKeys;
    vars.completedObjectiveNameKeys = vars.lastReadCompletedObjectiveNameKeys;
    vars.canSplitObjectivesThisFrame = true;

    foreach (var pair in vars.targetGuids)
    {
        string settingId = pair.Key;

        if (!settings[settingId])
        {
            continue;
        }

        if (vars.splittedObjectives.Contains(settingId) ||
            vars.pendingObjectiveSplits.Contains(settingId))
        {
            continue;
        }

        uint[] g = pair.Value;
        string targetGuid = vars.MakeGuidKey(g[0], g[1], g[2], g[3]);

        if (!vars.prevCompletedObjectiveGuids.Contains(targetGuid) &&
            vars.completedObjectiveGuids.Contains(targetGuid))
        {
            vars.pendingObjectiveSplits.Add(settingId);
        }
    }

    foreach (var pair in vars.targetNames)
    {
        string settingId = pair.Key;

        if (!settings[settingId])
        {
            continue;
        }

        if (vars.splittedObjectives.Contains(settingId) ||
            vars.pendingObjectiveSplits.Contains(settingId))
        {
            continue;
        }

        string targetKey = pair.Value;

        if (!vars.prevCompletedObjectiveNameKeys.Contains(targetKey) &&
            vars.completedObjectiveNameKeys.Contains(targetKey))
        {
            vars.pendingObjectiveSplits.Add(settingId);
        }
    }

    if (vars.lastCompletedObjectivesNum > vars.previousCompletedObjectivesNum)
    {
        vars.completedObjectivesNumIncreaseRecentFrames = 180;
    }
    else if (vars.completedObjectivesNumIncreaseRecentFrames > 0)
    {
        vars.completedObjectivesNumIncreaseRecentFrames--;
    }

    if (false && storyStateRead)
    {
        vars.debugStoryFrameCounter++;

        string storyStateLog =
            "activeStoryIndex=" + vars.activeStoryIndex +
            " storyEventConditionsComplete=" + vars.storyEventConditionsComplete +
            " completedObjectivesNum=" + vars.lastCompletedObjectivesNum +
            " lastCompletedObjectiveName=" + vars.lastCompletedObjectiveName +
            " lastCompletedObjectiveGuid=" + vars.lastCompletedObjectiveGuid;

        bool forceStoryStateLog = vars.debugStoryFrameCounter >= 120;

        if (storyStateLog != vars.lastLoggedStoryState || forceStoryStateLog)
        {
            if (forceStoryStateLog)
            {
                vars.debugStoryFrameCounter = 0;
            }

            vars.lastLoggedStoryState = storyStateLog;
            
            
        }

        if (vars.lastCompletedObjectivesNum > vars.previousCompletedObjectivesNum)
        {
            for (int i = vars.previousCompletedObjectivesNum; i < vars.lastCompletedObjectivesNum; i++)
            {
                if (i >= 0 && i < vars.currentCompletedObjectiveDebugRows.Count)
                {
                    
                }
            }
        }
    }

    return true;
}

split
{
    bool blockSplits =
        (version == "Epic" && current.moviePlayerLoading == 1) ||
        vars.suppressSplitThisUpdate ||
        !vars.isGameplayWorld;

    if (blockSplits)
    {
        return false;
    }

    if (settings["splits_bounty_state"])
    {
        foreach (var pair in vars.targetInfamySplits)
        {
            string settingId = pair.Key;

            if (!settings[settingId])
            {
                continue;
            }

            if (vars.splittedBountyState.Contains(settingId))
            {
                continue;
            }

            if (vars.pendingInfamySplits.Contains(settingId))
            {
                int targetInfamy = pair.Value;
                vars.pendingInfamySplits.Remove(settingId);
                vars.splittedBountyState.Add(settingId);
                
                return true;
            }
        }

        foreach (var pair in vars.targetDlcInfamySplits)
        {
            string settingId = pair.Key;

            if (!settings[settingId])
            {
                continue;
            }

            if (vars.splittedBountyState.Contains(settingId))
            {
                continue;
            }

            if (vars.pendingDlcInfamySplits.Contains(settingId))
            {
                int targetInfamy = pair.Value;
                vars.pendingDlcInfamySplits.Remove(settingId);
                vars.splittedBountyState.Add(settingId);
                
                return true;
            }
        }
    }

    if (settings["splits_player_state"])
    {
        foreach (var pair in vars.targetLevelSplits)
        {
            string settingId = pair.Key;

            if (!settings[settingId])
            {
                continue;
            }

            if (vars.splittedPlayerState.Contains(settingId))
            {
                continue;
            }

            if (vars.pendingPlayerLevelSplits.Contains(settingId))
            {
                int targetLevel = pair.Value;
                vars.pendingPlayerLevelSplits.Remove(settingId);
                vars.splittedPlayerState.Add(settingId);
                
                return true;
            }
        }

        foreach (var pair in vars.targetXPSplits)
        {
            string settingId = pair.Key;

            if (!settings[settingId])
            {
                continue;
            }

            if (vars.splittedPlayerState.Contains(settingId))
            {
                continue;
            }

            if (vars.pendingPlayerXPSplits.Contains(settingId))
            {
                int targetXp = pair.Value;
                vars.pendingPlayerXPSplits.Remove(settingId);
                vars.splittedPlayerState.Add(settingId);
                
                return true;
            }
        }
    }

    if (settings["objective_splits"])
    {
        foreach (var pair in vars.targetGuids)
        {
            string settingId = pair.Key;

            if (!settings[settingId])
            {
                continue;
            }

            if (vars.splittedObjectives.Contains(settingId))
            {
                continue;
            }

            if (vars.pendingObjectiveSplits.Contains(settingId))
            {
                uint[] g = pair.Value;
                string targetGuid = vars.MakeGuidKey(g[0], g[1], g[2], g[3]);
                vars.pendingObjectiveSplits.Remove(settingId);
                vars.splittedObjectives.Add(settingId);
                
                return true;
            }
        }

        foreach (var pair in vars.targetNames)
        {
            string settingId = pair.Key;

            if (!settings[settingId])
            {
                continue;
            }

            if (vars.splittedObjectives.Contains(settingId))
            {
                continue;
            }

            if (vars.pendingObjectiveSplits.Contains(settingId))
            {
                vars.pendingObjectiveSplits.Remove(settingId);
                vars.splittedObjectives.Add(settingId);
                
                return true;
            }
        }
    }

    if (settings["splits_story_state"])
    {
        foreach (var pair in vars.targetStorySplits)
        {
            string settingId = pair.Key;

            if (!settings[settingId])
            {
                continue;
            }

            if (vars.splittedStoryState.Contains(settingId))
            {
                continue;
            }

            if (vars.pendingStorySplits.Contains(settingId))
            {
                int targetActiveStoryIndex = pair.Value;
                vars.pendingStorySplits.Remove(settingId);
                vars.splittedStoryState.Add(settingId);
                
                return true;
            }
        }
    }

    if (settings["splits_story_state"] && vars.canSplitStoryStateThisFrame)
    {
        bool storyIndexAdvanced =
            vars.prevActiveStoryIndex > 0 &&
            vars.activeStoryIndex > vars.prevActiveStoryIndex &&
            vars.activeStoryIndex == vars.prevActiveStoryIndex + 1;

        bool storyAdvanceSupported =
            vars.lastCompletedObjectivesNum > vars.previousCompletedObjectivesNum ||
            vars.storyEventConditionsComplete > vars.prevStoryEventConditionsComplete ||
            vars.completedObjectivesNumIncreaseRecentFrames > 0;

        if (storyIndexAdvanced && storyAdvanceSupported)
        {
            foreach (var pair in vars.targetStorySplits)
            {
                string settingId = pair.Key;

                if (!settings[settingId])
                {
                    continue;
                }

                if (vars.splittedStoryState.Contains(settingId))
                {
                    continue;
                }

                int targetActiveStoryIndex = pair.Value;

                if (vars.activeStoryIndex == targetActiveStoryIndex)
                {
                    vars.splittedStoryState.Add(settingId);
                    
                    return true;
                }
            }
        }
    }

    if (settings["splits_bounty_state"] && vars.canSplitBountyStateThisFrame)
    {
        if (vars.isBaseGameWorld)
        {
            foreach (var pair in vars.targetInfamySplits)
            {
                string settingId = pair.Key;

                if (!settings[settingId])
                {
                    continue;
                }

                if (vars.splittedBountyState.Contains(settingId))
                {
                    continue;
                }

                int targetInfamy = pair.Value;

                if (vars.pendingInfamySplits.Contains(settingId))
                {
                    vars.pendingInfamySplits.Remove(settingId);
                    vars.splittedBountyState.Add(settingId);
                    
                    return true;
                }

                if (vars.prevInfamyLevel < targetInfamy &&
                    vars.infamyLevel >= targetInfamy)
                {
                    vars.splittedBountyState.Add(settingId);
                    
                    return true;
                }
            }
        }

        if (vars.isDlcWorld)
        {
            foreach (var pair in vars.targetDlcInfamySplits)
            {
                string settingId = pair.Key;

                if (!settings[settingId])
                {
                    continue;
                }

                if (vars.splittedBountyState.Contains(settingId))
                {
                    continue;
                }

                int targetInfamy = pair.Value;

                if (vars.pendingDlcInfamySplits.Contains(settingId))
                {
                    vars.pendingDlcInfamySplits.Remove(settingId);
                    vars.splittedBountyState.Add(settingId);
                    
                    return true;
                }

                if (vars.prevInfamyLevel < targetInfamy &&
                    vars.infamyLevel >= targetInfamy)
                {
                    vars.splittedBountyState.Add(settingId);
                    
                    return true;
                }
            }
        }
    }

    if (settings["splits_player_state"] && vars.canSplitPlayerStateThisFrame)
    {
        if (vars.playerStateLastValid && vars.canLevelSplit)
        {
            foreach (var pair in vars.targetLevelSplits)
            {
                string settingId = pair.Key;

                if (!settings[settingId])
                {
                    continue;
                }

                if (vars.splittedPlayerState.Contains(settingId))
                {
                    continue;
                }

                int targetLevel = pair.Value;

                if (vars.pendingPlayerLevelSplits.Contains(settingId))
                {
                    vars.pendingPlayerLevelSplits.Remove(settingId);
                    vars.splittedPlayerState.Add(settingId);
                    
                    return true;
                }

                if (targetLevel == 1 &&
                    vars.pendingLevel1SplitOnTutorialComplete &&
                    vars.playerCurrentPlayerLevel == 1)
                {
                    vars.pendingLevel1SplitOnTutorialComplete = false;
                    vars.splittedPlayerState.Add(settingId);
                    
                    return true;
                }

                int prevEffectiveLevel = vars.prevPlayerCurrentPlayerLevel;
                int effectiveLevel = vars.playerCurrentPlayerLevel;

                if (vars.prevPlayerTheoreticalPlayerLevel > prevEffectiveLevel)
                {
                    prevEffectiveLevel = vars.prevPlayerTheoreticalPlayerLevel;
                }

                if (vars.playerTheoreticalPlayerLevel > effectiveLevel)
                {
                    effectiveLevel = vars.playerTheoreticalPlayerLevel;
                }

                if (prevEffectiveLevel < targetLevel &&
                    effectiveLevel >= targetLevel)
                {
                    vars.splittedPlayerState.Add(settingId);
                    
                    return true;
                }
            }
        }

        foreach (var pair in vars.targetXPSplits)
        {
            string settingId = pair.Key;

            if (!settings[settingId])
            {
                continue;
            }

            if (vars.splittedPlayerState.Contains(settingId))
            {
                continue;
            }

            int targetXp = pair.Value;

            if (vars.pendingPlayerXPSplits.Contains(settingId))
            {
                vars.pendingPlayerXPSplits.Remove(settingId);
                vars.splittedPlayerState.Add(settingId);
                
                return true;
            }

            if (vars.prevPlayerCurrentExpAmount < targetXp &&
                vars.playerCurrentExpAmount >= targetXp)
            {
                vars.splittedPlayerState.Add(settingId);
                
                return true;
            }
        }
    }

    if (settings["objective_splits"] && vars.canSplitObjectivesThisFrame)
    {
        foreach (var pair in vars.targetGuids)
        {
            string settingId = pair.Key;

            if (!settings[settingId])
            {
                continue;
            }

            if (vars.splittedObjectives.Contains(settingId))
            {
                continue;
            }

            uint[] g = pair.Value;
            string targetGuid = vars.MakeGuidKey(g[0], g[1], g[2], g[3]);

            bool hadBefore = vars.prevCompletedObjectiveGuids.Contains(targetGuid);
            bool hasNow = vars.completedObjectiveGuids.Contains(targetGuid);

            if (false && hasNow)
            {
                
            }

            if (false && hasNow)
            {
                vars.splittedObjectives.Add(settingId);
                
                return true;
            }

            if (vars.pendingObjectiveSplits.Contains(settingId))
            {
                vars.pendingObjectiveSplits.Remove(settingId);
                vars.splittedObjectives.Add(settingId);
                
                return true;
            }

            if (!hadBefore && hasNow)
            {
                vars.splittedObjectives.Add(settingId);
                
                return true;
            }
        }

        foreach (var pair in vars.targetNames)
        {
            string settingId = pair.Key;

            if (!settings[settingId])
            {
                continue;
            }

            if (vars.splittedObjectives.Contains(settingId))
            {
                continue;
            }

            string targetKey = pair.Value;

            bool hadBefore = vars.prevCompletedObjectiveNameKeys.Contains(targetKey);
            bool hasNow = vars.completedObjectiveNameKeys.Contains(targetKey);

            if (vars.pendingObjectiveSplits.Contains(settingId))
            {
                vars.pendingObjectiveSplits.Remove(settingId);
                vars.splittedObjectives.Add(settingId);
                
                return true;
            }

            if (!hadBefore && hasNow)
            {
                vars.splittedObjectives.Add(settingId);
                
                return true;
            }
        }
    }

    return false;
}

reset
{
    return false;
}

isLoading
{
    return version == "Epic" && current.moviePlayerLoading == 1;
}



