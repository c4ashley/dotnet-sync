# dotnet-sync
## The Condition
I like C#. I also like Linux. I like Neovim, and I especially like it when my LSP works. For this, I use
[omnisharp-roslyn] along with [nvim-lspconfig] and [cmp-nvim-lsp] with no package manager or anything smart
like that. Sometimes this bites me in the butt, but it also means I have a more detailed understanding of
how my configuration works &mdash; or doesn't work &mdash; and hence I have a better chance at fixing it. I
also like to use the [latest .NET SDKs][dotnet8] because... well, I can't actually remember why I started
doing this. I don't think that I was missing out on the cutting-edge features of v8.0.204. I suspect it
started when .NET 8 was in Preview and the only way to use it was with a manual install. But here I am, still
keeping ahead of the distro, because when something goes wrong (which is often), I make sure I'm using the
most up-to-date tools.

## The Situation
*What the hell is a workload? Shouldn't the Runtime and SDK versions match? What?*

Whenever I install a .NET Framework, SDK or Runtimes that wasn't installed via my Linux distro's package
manager, I run into issues with those frameworks being inaccessible in certain cases. Sometimes, my `dotnet`
cli commands, such as `dotnet build`, will work fine, but I often run into trouble with, for example, my
OmniSharp LSP in Neovim being unable to resolve all the necessary assemblies. This results in endless
diagnostic red squiggles in my editor, with useless messages like:
* `C# Predefined type 'System.Object' is not defined or imported`
* `The type or namespace name 'Dictionary<,>' could not be found (are you missing a using directive or an assembly reference?) [CS0246]`
* Many others of a similar tone, not telling me anything useful.

Autocompletion shows a great many missing items, like when typing `System.Collections.Generic`, the
only available suggestions are a handful of interfaces and two Exception types.

The manual versions are in `$HOME/.dotnet`, but `dotnet` only searches `/usr/lib64/dotnet` by default.
Changing `DOTNET_ROOT` sometimes fixes some (or all) the problems, but may leave the "properly"
installed SDKs inaccessible, or create some other issues to do with the .NET Host, version mismatches, etc.

After getting everything working the first time, an update can break everything. It's hard to find what's
wrong, since the errors aren't very informative.

## The Description
*Just link 8.0.4... and shared... and packs, oh, this too... and...*

This is a simple script that searches your `$HOME/.dotnet` directory for any manually-installed packs, sdks,
manifests, etc, that aren't available in `/usr/lib64/dotnet`, and creates symbolic links to fill the gaps.
This makes manually-installed versions of .NET available without having to change your environment, keeping
your properly-installed versions of .NET available. Updates to the distro's dotnet packages may still break
the manuall-installed versions, so you'll have to run this script again after an update.

## The Execution
As of right now, this script will only work correctly if it is run from your user's home directory. This is
simply because `$HOME` doesn't evaluate properly under `sudo`, and I couldn't be bothered thinking of a more
robust workaround than just getting the home directory from the location of the script.

### To download:
```
cd       # Ensure we're in your home directory, for the reason mentioned above (... laziness)
wget https://raw.githubusercontent.com/c4ashley/dotnet-sync/master/dotnet-sync.sh
chmod +x dotnet-sync.sh
```

### To run:
```
sudo ./dotnet-sync.sh [-v|--verbose] [-d|--dry-run] [-h|--help]
```
**`-v|--verbose`**: Lists all the directories and versions in your `$HOME/.dotnet` directory as they are found,
and prints the linking commands as they are executed.

**`-d|--dry-run`**: Prevents the linking commands from actually being executed, only showing the commands that will be executed.



[omnisharp-roslyn]: https://github.com/OmniSharp/omnisharp-roslyn
[nvim-lspconfig]: https://github.com/neovim/nvim-lspconfig
[cmp-nvim-lsp]: https://github.com/hrsh7th/cmp-nvim-lsp
[dotnet8]: https://dotnet.microsoft.com/en-us/download/dotnet/8.0
