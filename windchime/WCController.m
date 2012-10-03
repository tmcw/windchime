//
//  WCController.m
//  windchime
//
//  Created by Tom MacWright on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WCController.h"
#include <AudioUnit/AudioUnit.h>
#include <AudioToolbox/AudioToolbox.h>

enum {
    kMidiMessageNoteOn        = 0x90,
    kMidiMessageNoteOff       = 0x80,
    kMidiMessageBassOn        = 0x91,
    kMidiMessageBassOff       = 0x81,
    kMidiMessageChordOn       = 0x92,
    kMidiMessageChordOff      = 0x82,
    kMidiMessageControlChange = 0xB0,
    kMidiMessageProgramChange = 0xC0};

@implementation WCController
- (id)init
{
    self = [super init];
    if (self)
    {
        self.scales = [[NSDictionary alloc] initWithObjectsAndKeys:
                       @[@24,@27,@31,@34,@36,@39,@43,@46,@48,@51,@55,@58,@60,@63,@67,@70,@72,@75,@79,@82,@84,@87,@91,@94,@96,@99,@103,@106,@108,@111,@115,@118],@"BiYu"
                       , @[@41,@42,@43,@46,@48,@51,@53,@54,@55,@58,@60,@63,@65,@66,@67,@70,@72,@75,@77,@78,@79,@82,@84,@87,@89,@90,@91,@94,@96,@99,@101,@102],@"Blues"
                       , @[@48,@49,@51,@52,@54,@55,@56,@58,@60,@61,@63,@64,@66,@67,@68,@70,@72,@73,@75,@76,@78,@79,@80,@82,@84,@85,@87,@88,@90,@91,@92,@94],@"Blues Diminished"
                       , @[@25,@27,@30,@32,@34,@37,@39,@42,@44,@46,@49,@51,@54,@56,@58,@61,@63,@66,@68,@70,@73,@75,@78,@80,@82,@85,@87,@90,@92,@94,@97,@99],@"Dorian"
                       , @[@51,@53,@55,@56,@57,@58,@59,@60,@62,@63,@65,@67,@68,@69,@70,@71,@72,@74,@75,@77,@79,@80,@81,@82,@83,@84,@86,@87,@89,@91,@92,@93],@"FullMinor"
                       , @[@44,@47,@48,@50,@52,@53,@55,@56,@59,@60,@62,@64,@65,@67,@68,@71,@72,@74,@76,@77,@79,@80,@83,@84,@86,@88,@89,@91,@92,@95,@96,@98],@"HarmonicMajor"
                       , @[@39,@43,@45,@47,@48,@50,@51,@55,@57,@59,@60,@62,@63,@67,@69,@71,@72,@74,@75,@79,@81,@83,@84,@86,@87,@91,@93,@95,@96,@98,@99,@103],@"Hawaiian"
                       , @[@45,@47,@48,@50,@52,@53,@56,@57,@59,@60,@62,@64,@65,@68,@69,@71,@72,@74,@76,@77,@80,@81,@83,@84,@86,@88,@89,@92,@93,@95,@96,@98],@"Ionian #5"
                       , @[@45,@47,@48,@50,@51,@53,@55,@57,@59,@60,@62,@63,@65,@67,@69,@71,@72,@74,@75,@77,@79,@81,@83,@84,@86,@87,@89,@91,@93,@95,@96,@98],@"Jazz Minor"
                       , @[@45,@47,@48,@50,@52,@54,@55,@57,@59,@60,@62,@64,@66,@67,@69,@71,@72,@74,@76,@78,@79,@81,@83,@84,@86,@88,@90,@91,@93,@95,@96,@98],@"Lydian"
                       , @[@43,@45,@48,@50,@51,@52,@54,@55,@57,@60,@62,@63,@64,@66,@67,@69,@72,@74,@75,@76,@78,@79,@81,@84,@86,@87,@88,@90,@91,@93,@96,@98],@"Major"
                       , @[@45,@46,@48,@50,@52,@53,@55,@57,@58,@60,@62,@64,@65,@67,@69,@70,@72,@74,@76,@77,@79,@81,@82,@84,@86,@88,@89,@91,@93,@94,@96,@98],@"Mixolydian"
                       , @[@45,@46,@48,@49,@52,@53,@54,@57,@58,@60,@61,@64,@65,@66,@69,@70,@72,@73,@76,@77,@78,@81,@82,@84,@85,@88,@89,@90,@93,@94,@96,@97],@"Oriental"
                       , @[@44,@46,@48,@49,@51,@52,@54,@56,@58,@60,@61,@63,@64,@66,@68,@70,@72,@73,@75,@76,@78,@80,@82,@84,@85,@87,@88,@90,@92,@94,@96,@97],@"Super Locrian"
                       , @[@46,@47,@48,@49,@52,@54,@56,@58,@59,@60,@61,@64,@66,@68,@70,@71,@72,@73,@76,@78,@80,@82,@83,@84,@85,@88,@90,@92,@94,@95,@96,@97],@"Verdi Enigmatic Ascending"
                       , @[@48,@50,@51,@53,@55,@56,@57,@59,@60,@62,@63,@65,@67,@68,@69,@71,@72,@74,@75,@77,@79,@80,@81,@83,@84,@86,@87,@89,@91,@92,@93,@95],@"Zirafkend",nil
                               ];
        self.instruments = @[@"Acoustic Grand Piano", @"Bright Acoustic Piano",
           @"Electric Grand Piano",@"Honky-tonk Piano",
           @"Electric Piano 1",@"Electric Piano 2",@"Harpsichord",
           @"Clavi",@"Celesta",@"Glockenspiel",@"Music Box",
           @"Vibraphone",@"Marimba",@"Xylophone",@"Tubular Bells",
           @"Dulcimer",@"Drawbar Organ",@"Percussive Organ",
           @"Rock Organ",@"Church Organ",@"Reed Organ",
           @"Accordion",@"Harmonica",@"Tango Accordion",
           @"Acoustic Guitar (nylon)",@"Acoustic Guitar (steel)",
           @"Electric Guitar (jazz)",@"Electric Guitar (clean)",
           @"Electric Guitar (muted)",@"Overdriven Guitar",
           @"Distortion Guitar",@"Guitar harmonics",
           @"Acoustic Bass",@"Electric Bass (finger)",
           @"Electric Bass (pick)",@"Fretless Bass",
           @"Slap Bass 1",@"Slap Bass 2",@"Synth Bass 1",
           @"Synth Bass 2",@"Violin",@"Viola",@"Cello",
           @"Contrabass",@"Tremolo Strings",@"Pizzicato Strings",
           @"Orchestral Harp",@"Timpani",@"String Ensemble 1",
           @"String Ensemble 2",@"SynthStrings 1",@"SynthStrings 2",
           @"Choir Aahs",@"Voice Oohs",@"Synth Voice",
           @"Orchestra Hit",@"Trumpet",@"Trombone",@"Tuba",
           @"Muted Trumpet",@"French Horn",@"Brass Section",
           @"SynthBrass 1",@"SynthBrass 2",@"Soprano Sax",
           @"Alto Sax",@"Tenor Sax",@"Baritone Sax",@"Oboe",
           @"English Horn",@"Bassoon",@"Clarinet",@"Piccolo",
           @"Flute",@"Recorder",@"Pan Flute",@"Blown Bottle",
           @"Shakuhachi",@"Whistle",@"Ocarina",@"Lead 1 (square)",
           @"Lead 2 (sawtooth)",@"Lead 3 (calliope)",@"Lead 4 (chiff)",
           @"Lead 5 (charang)",@"Lead 6 (voice)",@"Lead 7 (fifths)",
           @"Lead 8 (bass + lead)",@"Pad 1 (new age)",@"Pad 2 (warm)",
           @"Pad 3 (polysynth)",@"Pad 4 (choir)",@"Pad 5 (bowed)",
           @"Pad 6 (metallic)",@"Pad 7 (halo)",@"Pad 8 (sweep)",
           @"FX 1 (rain)",@"FX 2 (soundtrack)",@"FX 3 (crystal)",
           @"FX 4 (atmosphere)",@"FX 5 (brightness)",@"FX 6 (goblins)",
           @"FX 7 (echoes)",@"FX 8 (sci-fi)",@"Sitar",@"Banjo",
           @"Shamisen",@"Koto",@"Kalimba",@"Bag pipe",@"Fiddle",
           @"Shanai",@"Tinkle Bell",@"Agogo",@"Steel Drums",
           @"Woodblock",@"Taiko Drum",@"Melodic Tom",@"Synth Drum",
           @"Reverse Cymbal",@"Guitar Fret Noise",@"Breath Noise",
           @"Seashore",@"Bird Tweet",@"Telephone Ring",
           @"Helicopter",@"Applause",@"Gunshot"];
         
        NSString* tinyName = [[NSBundle mainBundle]
                              pathForResource:@"windchime"
                              ofType:@"png"];
        
        self.tiny = [[NSImage alloc] initWithContentsOfFile:tinyName];
        self.menu = [[NSMenu alloc] init];
        
        // Set up my status item
        self.statusItem = [[NSStatusBar systemStatusBar]
                       statusItemWithLength:NSVariableStatusItemLength];
        [self.statusItem setMenu:self.menu];
        [self.statusItem setToolTip:@"keypainting"];
        [self.statusItem setImage:self.tiny];
        [self.statusItem setHighlightMode:YES];
        
        self.instrumentMenu = [[NSMenu alloc] init];
        
        unsigned int idx = 0;
        for (id item in self.instruments) {
            id it = [self.instrumentMenu addItemWithTitle:item
                                           action:@selector(setInstrument:)
                                                    keyEquivalent:@""];
            [it setTarget:self];
            [it setRepresentedObject:[NSNumber numberWithUnsignedInt: idx]];
            idx++;
        }
        
        
        self.scaleMenu = [[NSMenu alloc] init];
        for (id item in self.scales) {
            NSLog(@"item: @%", item);
            id it = [self.scaleMenu addItemWithTitle:item
                                                   action:@selector(setScale:)
                                            keyEquivalent:@""];
            [it setTarget:self];
            [it setRepresentedObject:item];
        }
        
        self.instrumentMI = [[NSMenuItem alloc] init];
        [self.instrumentMI setTitle:NSLocalizedString(@"Instruments",@"")];
        [self.instrumentMI setSubmenu:self.instrumentMenu];
        [self.instrumentMI setTarget:self];
        
        
        self.scaleMI = [[NSMenuItem alloc] init];
        [self.scaleMI setTitle:NSLocalizedString(@"Scale (Dorian)",@"")];
        [self.scaleMI setSubmenu:self.scaleMenu];
        [self.scaleMI setTarget:self];
        
        self.aboutMI = [[NSMenuItem alloc]
                        initWithTitle:NSLocalizedString(@"About",@"")
                        action:@selector(about)
                        keyEquivalent:@""];
        [self.aboutMI setTarget:self];
        
        // Set up the menu
        self.quitMI = [[NSMenuItem alloc]
                   initWithTitle:NSLocalizedString(@"Quit",@"")
                   action:@selector(terminate:) 
                  keyEquivalent:@""];
        
        self.volumeMenu = [[NSMenu alloc] init];
        self.volumeMI = [[NSMenuItem alloc] initWithTitle:@"Volume (1)" action:nil keyEquivalent:@""];
        
        [self.volumeMI setSubmenu:self.volumeMenu];
        for (int vol = 1; vol <= 5; vol++) {
            id it = [self.volumeMenu addItemWithTitle:[NSString stringWithFormat:@"%d", vol]
                                                   action:@selector(setVolume:)
                                            keyEquivalent:@""];
            [it setTarget:self];
            [it setRepresentedObject:[NSNumber numberWithInt: vol]];
            idx++;
        }
        
        [self.menu addItem:self.aboutMI];
        [self.menu addItem:self.instrumentMI];
        [self.menu addItem:self.scaleMI];
        [self.menu addItem:self.volumeMI];
        [self.menu addItem:self.quitMI];
    }

    AUGraph graph;
    AUNode synthNode;
    AUNode outNode;
    ComponentDescription cd;
    cd.componentManufacturer = kAudioUnitManufacturer_Apple;
    cd.componentFlags = 0;
    cd.componentFlagsMask = 0;
    NewAUGraph(&graph);
    cd.componentType = kAudioUnitType_MusicDevice;
    cd.componentSubType = kAudioUnitSubType_DLSSynth;
    // New synthesizer node
    AUGraphNewNode(graph, &cd, 0, NULL, &synthNode);
    // Output
    cd.componentType = kAudioUnitType_Output;
    cd.componentSubType = kAudioUnitSubType_DefaultOutput;
    // New output node
    AUGraphNewNode(graph, &cd, 0, NULL, &outNode);
    // Open graph
    AUGraphOpen(graph);
    // Connect synthesizer node to output node
    AUGraphConnectNodeInput(graph, synthNode, 0, outNode, 0);
    // Get a synthesizer unit
    AUGraphGetNodeInfo(graph, synthNode, NULL, 0, NULL, &synthUnit);
    // Initialise
    AUGraphInitialize(graph);
    // Start
    AUGraphStart(graph);
    int instrument = 12;
    self->currentScale = @"Dorian";
    self->currentNotes = [self.scales valueForKey:self->currentScale];
    
    MusicDeviceMIDIEvent(synthUnit, kMidiMessageProgramChange + 0,
                         instrument, 0, 0);
    MusicDeviceMIDIEvent(synthUnit, kMidiMessageProgramChange + 1,
                         instrument, 0, 0);
    MusicDeviceMIDIEvent(synthUnit, kMidiMessageProgramChange + 2,
                         instrument, 0, 0);
    
    __block int level = 3;
    __block int lastnote = 0;
    self->volume = 10;


    //int jazzminor[32] = {45,47,48,50,51,53,55,57,59,60,62,63,65,67,69,71,72,74,75,77,79,81,83,84,86,87,89,91,93,95,96,98};
    //int lydian[32] = {45,47,48,50,52,54,55,57,59,60,62,64,66,67,69,71,72,74,76,78,79,81,83,84,86,88,90,91,93,95,96,98};
    
    /*
     http://www.lawriecape.co.uk/theblog/index.php/archives/881
     */

    [NSEvent
     addGlobalMonitorForEventsMatchingMask:NSKeyDownMask
     handler:^ (NSEvent *event) {
         int jazzminor[32] = {45,47,48,50,51,53,55,57,59,60,62,63,65,67,69,71,72,74,75,77,79,81,83,84,86,87,89,91,93,95,96,98};
         int lydian[32] = {45,47,48,50,52,54,55,57,59,60,62,64,66,67,69,71,72,74,76,78,79,81,83,84,86,88,90,91,93,95,96,98};
         int note = 0;
         if ([[event characters] isEqualToString:@"["] ||
             [[event characters] isEqualToString:@"{"] ||
             [[event characters] isEqualToString:@"("]) {
             level++;
         }  else if ([[event characters] isEqualToString:@"]"] ||
                  [[event characters] isEqualToString:@"}"] ||
                  [[event characters] isEqualToString:@")"]) {
             level--;
         }
         if (level < 0) { level = 0; }
         if (level > 1) { level = 1; }
         
         int idx = (int) [[event characters] characterAtIndex:0] % 32;
         note = [[self->currentNotes objectAtIndex:idx] intValue] + (12 * level);
         
         MusicDeviceMIDIEvent(synthUnit,
                              kMidiMessageNoteOff,
                              lastnote, self->volume, 0);
         
         MusicDeviceMIDIEvent(synthUnit,
                              kMidiMessageNoteOn,
                              note, self->volume, 0);
         
         lastnote = note;
     }];
    return self;
}

- (void)setInstrument:sender
{
    int instrument = [[sender representedObject] intValue];
    
    MusicDeviceMIDIEvent(self->synthUnit, kMidiMessageProgramChange + 0,
                         instrument, 0, 0);
    MusicDeviceMIDIEvent(self->synthUnit, kMidiMessageProgramChange + 1,
                         instrument, 0, 0);
    MusicDeviceMIDIEvent(self->synthUnit, kMidiMessageProgramChange + 2,
                         instrument, 0, 0);
}

- (void)setScale:sender
{
    self->currentScale = [sender representedObject];
    [self.scaleMI setTitle:[NSString stringWithFormat:@"Scale (%@)", self->currentScale]];
    self->currentNotes = [self.scales valueForKey:self->currentScale];
}

- (void)setVolume:sender
{
    self->volume = [[sender representedObject] intValue] * 20;
    [self.volumeMI setTitle:[NSString stringWithFormat:@"Volume (%d)", [[sender representedObject] intValue]]];
}

- (IBAction)about
{
    NSLog(@"Showing about window");
    NSApplication *app = [NSApplication sharedApplication];
    [app activateIgnoringOtherApps:YES];
    [app orderFrontStandardAboutPanel:self];
    NSLog(@"Window shown");
}
@end
