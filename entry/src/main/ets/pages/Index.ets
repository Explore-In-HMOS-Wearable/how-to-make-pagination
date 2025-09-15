import { rcp } from '@kit.RemoteCommunicationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Characters } from '../viewmodel/PaginationModel';
import { ComponentContent } from '@kit.ArkUI';


@Builder
function header() {
  Column() {
    Text("🧙 Game of Thrones Characters")
      .fontSize(16)
      .fontWeight(FontWeight.Bold)
      .textAlign(TextAlign.Center)
      .margin({ bottom: 8 })
  }
}

@Entry
@Component
struct PaginationPage {
  @State private items: string = ''
  @State private currentPage: number = 1
  private page1: string = 'anapioficeandfire.com/api/characters?page='
  private page2: string = 'anapioficeandfire.com/api/characters/'
  private readonly pageSize: number = 10
  @State chars: Characters[] = []
  context: UIContext = this.getUIContext()
  header: ComponentContent<object> = new ComponentContent(this.context, wrapBuilder(header))

  aboutToAppear(): void {
    this.loadPage()
  }

  build() {
    Flex({ justifyContent: FlexAlign.Center, wrap: FlexWrap.Wrap, alignItems: ItemAlign.Center }) {
      Button("🔄 Refresh Characters")
        .backgroundColor(`#4a7c59`)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .width('60%')
        .margin({ top: 8, bottom: 12 })
        .height(30)
        .borderRadius(16)
        .onClick(() => {
          this.loadPage()
        })

      Row() {
        Button("⬅️ Previous Page")
          .backgroundColor(`#6a9f84`)
          .width('45%')
          .height(26)
          .fontSize(13)
          .enabled(this.currentPage > 1)
          .borderRadius(12)
          .onClick(() => {
            if (this.currentPage > 1) {
              this.currentPage--
              this.loadPage()
            }
          })

        Button("Next Page ➡️")
          .height(26)
          .fontSize(13)
          .backgroundColor(`#6a9f84`)
          .width('45%')
          .borderRadius(12)
          .onClick(() => {
            this.currentPage++
            this.loadPage()
          })
      }
      .margin({ bottom: 14, top: 4 })
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)

      Text(`📄 Characters Page ${this.currentPage}`)
        .textAlign(TextAlign.Center)
        .fontSize(13)
        .margin({ bottom: 10 })
        .fontWeight(FontWeight.Medium)

      Flex({ justifyContent: FlexAlign.Center }) {
        List() {
          ForEach(this.chars, (char: Characters) => {
            ListItem() {
              Column() {
                Text(
                  `${char.name?.trim() !== '' ? char.name : (char.aliases?.[0] || 'Unnamed')}`
                )
                  .fontSize(13)
                  .fontWeight(FontWeight.Bold)
                  .textAlign(TextAlign.Start)

                Text(`Gender: ${char.gender || 'Unknown'}`)
                  .fontSize(11)
                  .fontWeight(FontWeight.Normal)
                  .opacity(0.8)
              }
              .onClick(() => {
                console.log(`Clicked on: ${char.name}`)
              })
              .backgroundColor(`#2f5f4f`)
              .padding({
                top: 6,
                bottom: 6,
                left: 10,
                right: 10
              })
              .margin({ bottom: 8 })
              .borderRadius(14)
              .width('90%')
            }
          }, (item: string, index: number) => item)
        }.alignListItem(ListItemAlign.Center)
      }
    }.backgroundColor(`#152f2b`).padding(16)
  }

  loadPage() {
    const url = `https://${this.page1}${this.currentPage}&pageSize=${this.pageSize}`
    const request = new rcp.Request(url, 'GET')
    const session = rcp.createSession()

    session.fetch(request).then((rep: rcp.Response) => {
      return rep.toJSON() as Characters[]
    }).then((data: Characters[]) => {
      this.chars = data

      let result: string = ''
      for (let i = 0; i < data.length; i++) {
        const character = data[i]
        const name = character.name?.trim() !== '' ? character.name : (character.aliases?.[0] || 'Unnamed')
        const gender = character.gender || 'Unknown'
        result += `${name} - ${gender}\n`
      }
      this.items = result

      console.log('Parsed characters:', this.items)
    }).catch((err: BusinessError) => {
      console.error(`Fetch error: ${err.code} - ${JSON.stringify(err)}`)
      this.items = 'Fetch error'
    })
  }

  deletePage() {
    const characterId = 583

    const url = `https://${this.page1}${characterId}`
    const request = new rcp.Request(url, 'DELETE')
    const session = rcp.createSession()

    session.fetch(request).then((rep: rcp.Response) => {
      if (rep) {
        console.log(`Character with ID ${characterId} deleted successfully`)
        this.loadPage()
      }
    }).catch((err: BusinessError) => {
      console.error(`Delete error: ${err.code} - ${JSON.stringify(err)}`)
    })
  }
}
